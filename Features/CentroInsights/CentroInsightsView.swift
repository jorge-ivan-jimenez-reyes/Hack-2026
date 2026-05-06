import SwiftUI
import Charts

/// Tab de "Insights" del Centro de Acopio. Diferenciador clave del producto:
/// el centro recibe inteligencia operacional (tendencias, heatmap, predicciones,
/// alertas auto-generadas) que la libreta jamás daría.
///
/// Secciones:
/// 1. Hero KPIs (3 cards con delta vs mes anterior)
/// 2. Tendencia 30 días (line chart con area gradient)
/// 3. Heatmap 7×24 (qué horas/días entran más cubetas)
/// 4. Top recolectores (horizontal bars)
/// 5. Distribución por zona (donut)
/// 6. Insights auto-generados ⭐ (la magia)
/// 7. Salud operacional (gauge + factores)
struct CentroInsightsView: View {
    private let data = CentroInsights.mock

    var body: some View {
        ZStack {
            Color.centroSurface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.l) {
                    header
                    heroKPIs
                    trendCard
                    heatmapCard
                    topRecolectoresCard
                    zoneDistributionCard
                    autoInsightsSection
                    healthCard
                    Color.clear.frame(height: 60)
                }
                .padding(.vertical, Spacing.s)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Insights")
                    .font(.appTitle2)
                    .foregroundStyle(.inkCharcoal)
                Text("Inteligencia operacional · \(data.monthLabel)")
                    .font(.appCallout)
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
            }
            Spacer()
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title2)
                .foregroundStyle(.forestDeep)
                .frame(width: 40, height: 40)
                .background(.forestDeep.opacity(0.15), in: .circle)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
    }

    // MARK: - Hero KPIs

    private var heroKPIs: some View {
        HStack(spacing: Spacing.s) {
            kpiCard(
                value: "\(data.kgThisMonth)",
                unit: "kg",
                label: "procesados",
                delta: data.kgGrowthPct,
                icon: "scalemass.fill",
                tint: .forestDeep
            )
            kpiCard(
                value: "\(data.activeRecolectores)",
                unit: "",
                label: "recolectores",
                delta: data.recolectorGrowthPct,
                icon: "person.3.fill",
                tint: .clay
            )
            kpiCard(
                value: String(format: "%.1f", data.cubetasPerDay),
                unit: "/día",
                label: "cubetas",
                delta: data.cubetasGrowthPct,
                icon: "circle.grid.3x3.fill",
                tint: .warning
            )
        }
        .padding(.horizontal, Spacing.l)
    }

    private func kpiCard(value: String, unit: String, label: String, delta: Int, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.18), in: .circle)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.appTitle2.weight(.bold))
                    .foregroundStyle(.inkCharcoal)
                    .contentTransition(.numericText())
                if !unit.isEmpty {
                    Text(unit)
                        .font(.appCaption)
                        .foregroundStyle(.inkCharcoal.opacity(0.55))
                }
            }

            Text(label)
                .font(.appCaption)
                .foregroundStyle(.inkCharcoal.opacity(0.60))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(spacing: 3) {
                Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 9, weight: .bold))
                Text("\(delta >= 0 ? "+" : "")\(delta)%")
                    .font(.system(.caption2, weight: .semibold))
            }
            .foregroundStyle(delta >= 0 ? Color.brand : Color.danger)
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: .inkCharcoal.opacity(0.06), radius: 10, y: 4)
        }
    }

    // MARK: - Trend (line chart 30 días)

    private var trendCard: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            sectionHeader(
                icon: "waveform.path.ecg",
                title: "Tendencia 30 días",
                badge: "kg/día"
            )

            Chart(data.dailyVolume) { point in
                AreaMark(
                    x: .value("Día", point.date),
                    y: .value("kg", point.kg)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.forestDeep.opacity(0.30), Color.forestDeep.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Día", point.date),
                    y: .value("kg", point.kg)
                )
                .foregroundStyle(Color.forestDeep)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine().foregroundStyle(.inkCharcoal.opacity(0.05))
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                        .font(.caption2)
                        .foregroundStyle(.inkCharcoal.opacity(0.55))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine().foregroundStyle(.inkCharcoal.opacity(0.05))
                    AxisValueLabel().font(.caption2).foregroundStyle(.inkCharcoal.opacity(0.55))
                }
            }
            .frame(height: 180)

            HStack(spacing: Spacing.l) {
                trendStat(label: "Pico", value: "\(Int(data.dailyVolume.map(\.kg).max() ?? 0)) kg")
                trendStat(label: "Promedio", value: "\(Int(data.dailyVolume.map(\.kg).reduce(0, +) / Double(data.dailyVolume.count))) kg")
                trendStat(label: "Total", value: "\(Int(data.dailyVolume.map(\.kg).reduce(0, +))) kg")
            }
        }
        .cardBackground()
    }

    private func trendStat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.appCaption)
                .foregroundStyle(.inkCharcoal.opacity(0.55))
            Text(value)
                .font(.appCallout.weight(.bold))
                .foregroundStyle(.inkCharcoal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Heatmap

    private var heatmapCard: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            sectionHeader(
                icon: "calendar.day.timeline.left",
                title: "Cuándo llegan las cubetas",
                badge: "7 días × 24 h"
            )

            Text("Pico martes 8 am · secundario jueves 6 pm")
                .font(.appCaption)
                .foregroundStyle(.inkCharcoal.opacity(0.60))

            HeatmapGrid(data: data.heatmap)
                .frame(height: 140)

            // Leyenda
            HStack(spacing: Spacing.s) {
                Text("Menos")
                    .font(.system(.caption2))
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
                HStack(spacing: 2) {
                    ForEach(0..<5) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.forestDeep.opacity(0.10 + Double(i) * 0.22))
                            .frame(width: 14, height: 10)
                    }
                }
                Text("Más")
                    .font(.system(.caption2))
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
                Spacer()
            }
        }
        .cardBackground()
    }

    // MARK: - Top recolectores

    private var topRecolectoresCard: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            sectionHeader(
                icon: "trophy.fill",
                title: "Top recolectores",
                badge: data.monthLabel
            )

            let maxKg = data.topRecolectores.map(\.kg).max() ?? 1

            VStack(spacing: Spacing.s) {
                ForEach(Array(data.topRecolectores.enumerated()), id: \.element.id) { idx, r in
                    topRecolectorRow(rank: idx + 1, recolector: r, maxKg: maxKg)
                }
            }
        }
        .cardBackground()
    }

    private func topRecolectorRow(rank: Int, recolector: TopRecolector, maxKg: Int) -> some View {
        let ratio = Double(recolector.kg) / Double(maxKg)
        let tint: Color = rank == 1 ? .clay : (rank == 2 ? .forestDeep : (rank == 3 ? .warning : .moss))

        return HStack(spacing: Spacing.s) {
            // Rank
            Text("#\(rank)")
                .font(.appCaption.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 28, alignment: .leading)

            // Nombre
            Text(recolector.name)
                .font(.appBody.weight(.medium))
                .foregroundStyle(.inkCharcoal)
                .lineLimit(1)
                .frame(width: 110, alignment: .leading)

            // Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(tint.opacity(0.12))
                    Capsule().fill(tint.opacity(0.55))
                        .frame(width: geo.size.width * ratio)
                }
            }
            .frame(height: 8)

            // Kg
            Text("\(recolector.kg) kg")
                .font(.appCaption.weight(.semibold))
                .foregroundStyle(.inkCharcoal)
                .monospacedDigit()
                .frame(width: 56, alignment: .trailing)
        }
    }

    // MARK: - Zone distribution (donut)

    private var zoneDistributionCard: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            sectionHeader(
                icon: "map.fill",
                title: "Distribución por zona",
                badge: "% volumen"
            )

            HStack(spacing: Spacing.l) {
                DonutChart(slices: data.zoneDistribution)
                    .frame(width: 120, height: 120)

                VStack(alignment: .leading, spacing: Spacing.s) {
                    ForEach(data.zoneDistribution) { slice in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(slice.tint)
                                .frame(width: 10, height: 10)
                            Text(slice.name)
                                .font(.appCallout)
                                .foregroundStyle(.inkCharcoal)
                            Spacer()
                            Text("\(Int(slice.pct * 100))%")
                                .font(.appCallout.weight(.bold))
                                .foregroundStyle(.inkCharcoal)
                                .monospacedDigit()
                        }
                    }
                }
            }
        }
        .cardBackground()
    }

    // MARK: - Auto-insights ⭐

    private var autoInsightsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.forestDeep)
                    .symbolEffect(.variableColor.iterative.reversing, options: .repeat(.continuous))
                Text("Insights del sistema")
                    .font(.appHeadline.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                Spacer()
                Text("\(data.autoInsights.count) hallazgos")
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
            }
            .padding(.horizontal, Spacing.l)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.m) {
                    ForEach(data.autoInsights) { insight in
                        autoInsightCard(insight)
                    }
                }
                .padding(.horizontal, Spacing.l)
            }
        }
    }

    private func autoInsightCard(_ insight: AutoInsight) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(spacing: 6) {
                Image(systemName: insight.kind.icon)
                    .font(.callout)
                    .foregroundStyle(insight.kind.tint)
                Text(insight.kind.label)
                    .font(.system(.caption2, weight: .heavy))
                    .foregroundStyle(insight.kind.tint)
                    .tracking(0.8)
            }

            Text(insight.title)
                .font(.appHeadline.weight(.bold))
                .foregroundStyle(.inkCharcoal)
                .fixedSize(horizontal: false, vertical: true)

            Text(insight.body)
                .font(.appCallout)
                .foregroundStyle(.inkCharcoal.opacity(0.70))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(Spacing.l)
        .frame(width: 280, height: 180, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: insight.kind.tint.opacity(0.18), radius: 14, y: 6)
        }
        .overlay(alignment: .topTrailing) {
            // Glow corner del tint
            Circle()
                .fill(insight.kind.tint.opacity(0.18))
                .frame(width: 80, height: 80)
                .blur(radius: 30)
                .offset(x: 20, y: -20)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.l))
    }

    // MARK: - Health

    private var healthCard: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            sectionHeader(
                icon: "heart.fill",
                title: "Salud operacional",
                badge: nil
            )

            HStack(spacing: Spacing.l) {
                HealthGauge(score: data.healthScore)
                    .frame(width: 110, height: 110)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(data.healthBreakdown) { factor in
                        HStack(spacing: 8) {
                            Image(systemName: factor.icon)
                                .font(.caption)
                                .foregroundStyle(.forestDeep)
                                .frame(width: 22)
                            Text(factor.label)
                                .font(.appCaption)
                                .foregroundStyle(.inkCharcoal)
                                .lineLimit(1)
                            Spacer(minLength: 4)
                            Text("\(factor.score)")
                                .font(.appCaption.weight(.bold))
                                .foregroundStyle(scoreTint(factor.score))
                                .monospacedDigit()
                        }
                    }
                }
            }
        }
        .cardBackground()
    }

    private func scoreTint(_ score: Int) -> Color {
        if score >= 85 { return .brand }
        if score >= 70 { return .forestDeep }
        if score >= 50 { return .warning }
        return .danger
    }

    // MARK: - Reusable header

    private func sectionHeader(icon: String, title: String, badge: String?) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.forestDeep)
            Text(title)
                .font(.appHeadline.weight(.semibold))
                .foregroundStyle(.inkCharcoal)
            Spacer()
            if let badge {
                Text(badge)
                    .font(.appCaption.weight(.semibold))
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
            }
        }
    }
}

// MARK: - HeatmapGrid

private struct HeatmapGrid: View {
    let data: [[Double]]   // 7 × 24

    private let dayLabels = ["L", "M", "X", "J", "V", "S", "D"]

    var body: some View {
        GeometryReader { geo in
            let columns = 24
            let rows = 7
            let spacing: CGFloat = 2
            let labelW: CGFloat = 18
            let availableW = geo.size.width - labelW
            let cellW = (availableW - spacing * CGFloat(columns - 1)) / CGFloat(columns)
            let cellH = (geo.size.height - spacing * CGFloat(rows - 1)) / CGFloat(rows)

            HStack(alignment: .top, spacing: 2) {
                // Day labels
                VStack(spacing: spacing) {
                    ForEach(0..<rows, id: \.self) { d in
                        Text(dayLabels[d])
                            .font(.system(.caption2, weight: .semibold))
                            .foregroundStyle(.inkCharcoal.opacity(0.55))
                            .frame(width: labelW, height: cellH, alignment: .center)
                    }
                }
                .frame(width: labelW)

                // Grid
                VStack(spacing: spacing) {
                    ForEach(0..<rows, id: \.self) { d in
                        HStack(spacing: spacing) {
                            ForEach(0..<columns, id: \.self) { h in
                                let intensity = data[d][h]
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.forestDeep.opacity(0.08 + intensity * 0.85))
                                    .frame(width: cellW, height: cellH)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - DonutChart

private struct DonutChart: View {
    let slices: [ZoneSlice]

    var body: some View {
        ZStack {
            ForEach(Array(slicesWithOffsets.enumerated()), id: \.offset) { _, item in
                Circle()
                    .trim(from: item.start, to: item.end)
                    .stroke(item.tint, style: StrokeStyle(lineWidth: 22, lineCap: .butt))
                    .rotationEffect(.degrees(-90))
            }

            VStack(spacing: 0) {
                Text("\(slices.count)")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(.inkCharcoal)
                Text("zonas")
                    .font(.system(.caption2))
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
            }
        }
    }

    /// Acumula los pcts a un offset 0..1 para usar con .trim.
    private var slicesWithOffsets: [(start: Double, end: Double, tint: Color)] {
        var acc: Double = 0
        return slices.map { s in
            let start = acc
            acc += s.pct
            return (start, min(acc, 1), s.tint)
        }
    }
}

// MARK: - HealthGauge

private struct HealthGauge: View {
    let score: Int

    var body: some View {
        ZStack {
            // Track
            Circle()
                .trim(from: 0.10, to: 0.90)
                .stroke(Color.inkCharcoal.opacity(0.08), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(90))

            // Fill
            Circle()
                .trim(from: 0.10, to: 0.10 + 0.80 * Double(score) / 100)
                .stroke(
                    LinearGradient(
                        colors: [.warning, .forestDeep, .brand],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(90))

            VStack(spacing: 0) {
                Text("\(score)")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(.inkCharcoal)
                    .contentTransition(.numericText())
                Text("salud")
                    .font(.system(.caption2))
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
            }
        }
    }
}

// MARK: - Helpers

private extension View {
    /// Background blanco + shadow + padding del card estándar de Insights.
    func cardBackground() -> some View {
        self
            .padding(Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(.white)
                    .shadow(color: Color.inkCharcoal.opacity(0.06), radius: 10, y: 4)
            }
            .padding(.horizontal, Spacing.l)
    }
}

#Preview {
    CentroInsightsView()
}
