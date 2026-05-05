import WidgetKit
import SwiftUI

/// Widget Home Screen — muestra progreso de la cubeta actual y posición en el ciclo 15:1.
/// Disponible en small y medium. Lee de App Group / UserDefaults compartidos.
struct CubetaProgressWidget: Widget {
    let kind: String = "CubetaProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CubetaTimelineProvider()) { entry in
            CubetaWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Tu cubeta")
        .description("Progreso de tu cubeta actual y ciclo 15:1.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct CubetaEntry: TimelineEntry {
    let date: Date
    let bucketProgress: Double   // 0...1
    let bucketsCompleted: Int    // 0...15
    let totalKgDiverted: Double
}

struct CubetaTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> CubetaEntry {
        CubetaEntry(date: .now, bucketProgress: 0.47, bucketsCompleted: 7, totalKgDiverted: 42.3)
    }

    func getSnapshot(in context: Context, completion: @escaping (CubetaEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CubetaEntry>) -> Void) {
        let entry = loadEntry()
        // Refresca cada 30 min — el progreso real cambia poco.
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    /// Lee del UserDefaults compartido. Si no hay datos, regresa estado vacío.
    /// TODO día del hack: configurar App Group "group.mx.up.ioslab.hacknacional2026"
    /// y cambiar a UserDefaults(suiteName:) para datos compartidos reales.
    private func loadEntry() -> CubetaEntry {
        let defaults = UserDefaults.standard
        return CubetaEntry(
            date: .now,
            bucketProgress: defaults.object(forKey: "widget.bucketProgress") as? Double ?? 0,
            bucketsCompleted: defaults.integer(forKey: "widget.bucketsCompleted"),
            totalKgDiverted: defaults.object(forKey: "widget.totalKg") as? Double ?? 0
        )
    }
}

struct CubetaWidgetView: View {
    let entry: CubetaEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall: smallView
        default:           mediumView
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "leaf.fill")
                    .font(.caption.weight(.semibold))
                Text("Tu cubeta")
                    .font(.caption.weight(.semibold))
                Spacer()
            }
            .foregroundStyle(.green)

            Text("\(Int(entry.bucketProgress * 100))%")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .contentTransition(.numericText())

            ProgressView(value: entry.bucketProgress)
                .tint(.green)

            Text("\(entry.bucketsCompleted)/15 al abono")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var mediumView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "leaf.fill")
                    Text("Tu cubeta")
                        .font(.callout.weight(.semibold))
                }
                .foregroundStyle(.green)

                Text("\(Int(entry.bucketProgress * 100))%")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())

                ProgressView(value: entry.bucketProgress)
                    .tint(.green)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                rowStat(value: "\(entry.bucketsCompleted)/15", label: "Hacia abono", icon: "circle.grid.3x3.fill")
                rowStat(value: kgString(entry.totalKgDiverted), label: "kg desviados", icon: "scalemass.fill")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func rowStat(value: String, label: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.green)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.callout.weight(.bold))
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func kgString(_ kg: Double) -> String {
        kg < 10 ? String(format: "%.1f", kg) : "\(Int(kg))"
    }
}

#Preview(as: .systemSmall) {
    CubetaProgressWidget()
} timeline: {
    CubetaEntry(date: .now, bucketProgress: 0.47, bucketsCompleted: 7, totalKgDiverted: 42.3)
}

#Preview(as: .systemMedium) {
    CubetaProgressWidget()
} timeline: {
    CubetaEntry(date: .now, bucketProgress: 0.47, bucketsCompleted: 7, totalKgDiverted: 42.3)
}
