import SwiftUI
import SwiftData

/// Historial del recolector — timeline mezclando escaneos, entregas al centro
/// y abono recibido. Stats arriba, filtros con chips, lista agrupada por fecha.
struct HistoryView: View {
    @Query(sort: \ScanRecord.createdAt, order: .reverse) private var scanRecords: [ScanRecord]
    @Environment(\.modelContext) private var context

    @State private var filter: Filter = .all
    @State private var bouncePulse = 0

    enum Filter: String, CaseIterable, Identifiable {
        case all, scan, delivery, abono
        var id: String { rawValue }
        var label: String {
            switch self {
            case .all:      "Todo"
            case .scan:     "Escaneos"
            case .delivery: "Entregas"
            case .abono:    "Abono"
            }
        }
        var icon: String {
            switch self {
            case .all:      "rectangle.stack.fill"
            case .scan:     "camera.viewfinder"
            case .delivery: "tray.full.fill"
            case .abono:    "leaf.fill"
            }
        }
    }

    /// Mezcla scans reales (SwiftData) + mocks de delivery/abono. Cuando
    /// la persistencia esté lista se reemplazan los mocks.
    private var allEvents: [HistoryEvent] {
        let scans = scanRecords.map {
            HistoryEvent.scan(id: $0.id, date: $0.createdAt, category: $0.category, summary: $0.summary)
        }
        return (scans + HistoryMock.events()).sorted { $0.date > $1.date }
    }

    private var filteredEvents: [HistoryEvent] {
        switch filter {
        case .all:      allEvents
        case .scan:     allEvents.filter { if case .scan = $0 { true } else { false } }
        case .delivery: allEvents.filter { if case .delivery = $0 { true } else { false } }
        case .abono:    allEvents.filter { if case .abono = $0 { true } else { false } }
        }
    }

    private var groupedByDay: [(key: Date, events: [HistoryEvent])] {
        let cal = Calendar.current
        let groups = Dictionary(grouping: filteredEvents) { event in
            cal.startOfDay(for: event.date)
        }
        return groups
            .map { (key: $0.key, events: $0.value) }
            .sorted { $0.key > $1.key }
    }

    private var totals: (kgEntregados: Double, cubetas: Int, kgAbono: Double) {
        var kgEntregados = 0.0
        var cubetas = 0
        var kgAbono = 0.0
        for event in allEvents {
            switch event {
            case .delivery(_, _, let kg, _):
                kgEntregados += kg
                cubetas += 1
            case .abono(_, _, let kg):
                kgAbono += kg
            case .scan: break
            }
        }
        return (kgEntregados, cubetas, kgAbono)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cream.ignoresSafeArea()

                if allEvents.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: Spacing.l) {
                            statsCard
                            filterChips
                            timeline
                            Color.clear.frame(height: 40)
                        }
                        .padding(.vertical, Spacing.s)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("Historial")
            .navigationBarTitleDisplayMode(.large)
            .animation(AppAnimation.smooth, value: filter)
        }
    }

    // MARK: - Stats

    private var statsCard: some View {
        HStack(spacing: Spacing.l) {
            statBlock(value: kgString(totals.kgEntregados), unit: "kg", label: "Entregados", icon: "tray.full.fill", tint: .clay)
            statBlock(value: "\(totals.cubetas)", unit: "", label: "Cubetas", icon: "circle.grid.3x3.fill", tint: .brand)
            statBlock(value: kgString(totals.kgAbono), unit: "kg", label: "Abono", icon: "leaf.fill", tint: .moss)
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.06), radius: 10, y: 4)
        }
        .padding(.horizontal, Spacing.l)
    }

    private func statBlock(value: String, unit: String, label: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.15), in: .circle)
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
                .foregroundStyle(.inkCharcoal.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Filter chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Filter.allCases) { f in
                    Button {
                        Haptics.tap()
                        withAnimation(AppAnimation.spring) { filter = f }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: f.icon)
                                .font(.caption)
                            Text(f.label)
                                .font(.appCallout.weight(.semibold))
                        }
                        .foregroundStyle(filter == f ? .white : .inkCharcoal)
                        .padding(.horizontal, Spacing.m)
                        .padding(.vertical, Spacing.s)
                        .background {
                            Capsule()
                                .fill(filter == f ? Color.brand : Color.white)
                                .shadow(color: Color.inkCharcoal.opacity(0.06), radius: 4, y: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.l)
        }
    }

    // MARK: - Timeline

    private var timeline: some View {
        VStack(spacing: Spacing.l) {
            ForEach(groupedByDay, id: \.key) { group in
                dayGroup(date: group.key, events: group.events)
            }
            if filteredEvents.isEmpty {
                emptyFilter
            }
        }
        .padding(.horizontal, Spacing.l)
    }

    private func dayGroup(date: Date, events: [HistoryEvent]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(date.formatted(.dateTime.weekday(.wide).day().month(.abbreviated)).capitalized)
                .font(.appCallout.weight(.semibold))
                .foregroundStyle(.inkCharcoal.opacity(0.55))
                .padding(.horizontal, Spacing.s)

            VStack(spacing: 0) {
                ForEach(events) { event in
                    timelineRow(event)
                    if event.id != events.last?.id {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(.white)
                    .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 8, y: 3)
            }
        }
    }

    private func timelineRow(_ event: HistoryEvent) -> some View {
        HStack(alignment: .top, spacing: Spacing.m) {
            ZStack {
                Circle().fill(event.color.opacity(0.15))
                Image(systemName: event.icon)
                    .font(.callout)
                    .foregroundStyle(event.color)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.appBody.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                Text(event.subtitle)
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
                    .lineLimit(2)
            }
            Spacer(minLength: 8)
            Text(event.date.formatted(.dateTime.hour().minute()))
                .font(.appCaption)
                .foregroundStyle(.inkCharcoal.opacity(0.45))
        }
        .padding(Spacing.m)
    }

    // MARK: - Empty states

    private var emptyState: some View {
        EmptyStateView(
            icon: "tray",
            title: "Tu historial empezará a llenarse",
            subtitle: "Aquí verás tus escaneos, entregas al centro y el abono que recibas."
        )
    }

    private var emptyFilter: some View {
        EmptyStateView(
            icon: "line.3.horizontal.decrease.circle",
            title: "Sin eventos en este filtro",
            subtitle: "Cambia el filtro para ver más actividad."
        )
    }

    private func kgString(_ kg: Double) -> String {
        kg < 10 ? String(format: "%.1f", kg) : "\(Int(kg))"
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: ScanRecord.self, inMemory: true)
}
