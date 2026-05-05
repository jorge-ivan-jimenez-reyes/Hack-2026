import SwiftUI

/// Tab "Lotes" del Centro de Acopio. Lista todos los lotes activos
/// con badge de risk según el análisis de salud. Tap abre detalle.
struct BatchListView: View {
    @State private var batches: [CompostBatch] = CompostBatch.mock
    @State private var selectedBatch: CompostBatch?
    @State private var filter: BatchFilter = .all

    private var filtered: [CompostBatch] {
        filter.apply(to: batches)
    }

    private var activeCount: Int { batches.count }
    private var atRiskCount: Int {
        batches.filter { BatchHealthAnalyzer.diagnose($0).risk != .low }.count
    }

    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.l) {
                    header
                    summaryCard
                    filtersRow
                    batchList
                    Color.clear.frame(height: 80)
                }
                .padding(.vertical, Spacing.s)
            }
            .scrollIndicators(.hidden)
        }
        .sheet(item: $selectedBatch) { batch in
            BatchDetailView(batch: batch)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Lotes activos")
                    .font(.appTitle2)
                    .foregroundStyle(.inkCharcoal)
                Text("\(activeCount) en proceso · \(atRiskCount) requieren atención")
                    .font(.appCallout)
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
            }
            Spacer()
            Image(systemName: "leaf.arrow.circlepath")
                .font(.system(size: 28))
                .foregroundStyle(.brand)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
    }

    /// Card resumen con stats globales
    private var summaryCard: some View {
        let totalKg: Int = batches.count * 180     // estimado
        let totalCo2: Int = Int(Double(totalKg) * 1.9)

        return HStack(spacing: Spacing.l) {
            statBlock(value: "\(totalKg)", unit: "kg", label: "procesando", icon: "scalemass.fill", tint: .brand)
            Divider().frame(height: 50)
            statBlock(value: "\(totalCo2)", unit: "kg", label: "CO₂ evitado", icon: "leaf.fill", tint: .moss)
            Divider().frame(height: 50)
            statBlock(value: "\(activeCount)", unit: "lotes", label: "activos", icon: "square.stack.3d.up.fill", tint: .clay)
        }
        .padding(Spacing.l)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 8, y: 3)
        }
        .padding(.horizontal, Spacing.l)
    }

    private func statBlock(value: String, unit: String, label: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(tint)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.appTitle2.weight(.bold))
                    .foregroundStyle(.inkCharcoal)
                Text(unit)
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
            }
            Text(label)
                .font(.appCaption)
                .foregroundStyle(.inkCharcoal.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var filtersRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(BatchFilter.allCases) { f in
                    filterChip(f)
                }
            }
            .padding(.horizontal, Spacing.l)
        }
    }

    private func filterChip(_ f: BatchFilter) -> some View {
        let selected = (filter == f)
        return Button {
            Haptics.tap()
            withAnimation(.snappy(duration: 0.25)) { filter = f }
        } label: {
            Text(f.rawValue)
                .font(.appCallout.weight(.medium))
                .foregroundStyle(selected ? Color.cream : .inkCharcoal)
                .padding(.horizontal, Spacing.m)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(selected ? Color.brand : .white)
                        .shadow(
                            color: selected ? Color.brand.opacity(0.18) : Color.inkCharcoal.opacity(0.05),
                            radius: selected ? 6 : 3,
                            y: 2
                        )
                }
        }
        .buttonStyle(.plain)
    }

    private var batchList: some View {
        VStack(spacing: Spacing.s) {
            ForEach(filtered) { batch in
                batchRow(batch)
            }
        }
        .padding(.horizontal, Spacing.l)
    }

    private func batchRow(_ batch: CompostBatch) -> some View {
        let diagnostic = BatchHealthAnalyzer.diagnose(batch)
        return Button {
            Haptics.tap()
            selectedBatch = batch
        } label: {
            HStack(alignment: .center, spacing: Spacing.m) {
                // Icon con risk tint
                ZStack {
                    Circle().fill(diagnostic.risk.tint.opacity(0.18))
                    Image(systemName: diagnostic.risk.symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(diagnostic.risk.tint)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(batch.name)
                            .font(.appBody.weight(.semibold))
                            .foregroundStyle(.inkCharcoal)
                        Spacer()
                        Text("Riesgo \(diagnostic.risk.rawValue)")
                            .font(.appCaption.weight(.semibold))
                            .foregroundStyle(diagnostic.risk.tint)
                            .padding(.horizontal, Spacing.s)
                            .padding(.vertical, 3)
                            .background(diagnostic.risk.tint.opacity(0.15), in: .capsule)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "clock").font(.caption2)
                        Text("\(batch.daysInProcess) días")
                        Text("·")
                        Image(systemName: "thermometer").font(.caption2)
                        Text("\(Int(batch.temperatureCelsius))°C")
                        Text("·")
                        Image(systemName: "humidity.fill").font(.caption2)
                        Text("\(Int(batch.humidityPercent))%")
                    }
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.55))

                    Text(diagnostic.title)
                        .font(.appCaption)
                        .foregroundStyle(.inkCharcoal.opacity(0.75))
                        .lineLimit(1)
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.inkCharcoal.opacity(0.30))
            }
            .padding(Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(.white)
                    .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 6, y: 2)
            }
        }
        .buttonStyle(.plain)
    }
}

enum BatchFilter: String, CaseIterable, Identifiable {
    case all = "Todos"
    case atRisk = "Con riesgo"
    case healthy = "Saludables"
    case ready = "Por cosechar"

    var id: String { rawValue }

    func apply(to batches: [CompostBatch]) -> [CompostBatch] {
        switch self {
        case .all:     return batches
        case .atRisk:  return batches.filter { BatchHealthAnalyzer.diagnose($0).risk != .low }
        case .healthy: return batches.filter { BatchHealthAnalyzer.diagnose($0).risk == .low && $0.phase != .curing }
        case .ready:   return batches.filter { $0.phase == .curing }
        }
    }
}

#Preview {
    BatchListView()
}
