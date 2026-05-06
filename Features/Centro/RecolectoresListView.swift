import SwiftUI

/// Lista de recolectores registrados en el centro. Búsqueda + filtros +
/// rows con progreso 15:1 visual + badge cuando toca dar abono.
struct RecolectoresListView: View {
    @State private var search: String = ""
    @State private var filter: RecolectorFilter = .all

    private let allEntries = RecolectorEntry.mock

    private var filtered: [RecolectorEntry] {
        let byFilter = filter.apply(to: allEntries)
        guard !search.isEmpty else { return byFilter }
        return byFilter.filter {
            $0.name.localizedCaseInsensitiveContains(search) ||
            $0.alcaldia.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        ZStack {
            Color.centroSurface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.l) {
                    header
                    searchField
                    filtersRow
                    rosterList
                    Color.clear.frame(height: 80)
                }
                .padding(.vertical, Spacing.s)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Recolectores")
                    .font(.appTitle2)
                    .foregroundStyle(.inkCharcoal)
                Text("\(allEntries.count) registrados · \(allEntries.filter(\.isActive).count) activos")
                    .font(.appCallout)
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
            }
            Spacer()
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 28))
                .foregroundStyle(.brand)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
    }

    private var searchField: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.inkCharcoal.opacity(0.45))
            TextField("Buscar nombre o alcaldía", text: $search)
                .textFieldStyle(.plain)
                .font(.appBody)
                .foregroundStyle(.inkCharcoal)
            if !search.isEmpty {
                Button {
                    Haptics.tap()
                    search = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.inkCharcoal.opacity(0.30))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, 10)
        .background {
            Capsule().fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 6, y: 2)
        }
        .padding(.horizontal, Spacing.l)
    }

    private var filtersRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(RecolectorFilter.allCases) { f in
                    filterChip(f)
                }
            }
            .padding(.horizontal, Spacing.l)
        }
    }

    private func filterChip(_ f: RecolectorFilter) -> some View {
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

    private var rosterList: some View {
        VStack(spacing: Spacing.s) {
            if filtered.isEmpty {
                emptyState
            } else {
                ForEach(filtered) { entry in
                    recolectorRow(entry)
                }
            }
        }
        .padding(.horizontal, Spacing.l)
    }

    private func recolectorRow(_ entry: RecolectorEntry) -> some View {
        HStack(spacing: Spacing.m) {
            avatar(initials: entry.initials, ready: entry.readyForAbono)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entry.name)
                        .font(.appBody.weight(.semibold))
                        .foregroundStyle(.inkCharcoal)
                    Spacer()
                    if entry.readyForAbono {
                        Text("✨ Dar abono")
                            .font(.appCaption.weight(.semibold))
                            .foregroundStyle(.brand)
                            .padding(.horizontal, Spacing.s)
                            .padding(.vertical, 3)
                            .background(.brand.opacity(0.15), in: .capsule)
                    } else if !entry.isActive {
                        Text("Inactivo")
                            .font(.appCaption.weight(.semibold))
                            .foregroundStyle(.warning)
                            .padding(.horizontal, Spacing.s)
                            .padding(.vertical, 3)
                            .background(.warning.opacity(0.15), in: .capsule)
                    }
                }

                progressDots(completed: entry.bucketsCompleted)

                HStack(spacing: 4) {
                    Image(systemName: "mappin").font(.caption2)
                    Text(entry.alcaldia)
                    Text("·")
                    Image(systemName: "clock").font(.caption2)
                    Text(deliveryAgo(entry.lastDeliveryDaysAgo))
                }
                .font(.appCaption)
                .foregroundStyle(.inkCharcoal.opacity(0.55))
            }
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 6, y: 2)
        }
    }

    private func avatar(initials: String, ready: Bool) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: ready ? [.brand, .brand.opacity(0.7)] : [.moss.opacity(0.6), .moss.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(initials)
                .font(.appCallout.weight(.bold))
                .foregroundStyle(.cream)
        }
        .frame(width: 44, height: 44)
    }

    /// 15 dots horizontales, los completados llenos en brand.
    private func progressDots(completed: Int) -> some View {
        HStack(spacing: 3) {
            ForEach(0..<15, id: \.self) { i in
                Capsule()
                    .fill(i < completed ? Color.brand : Color.brand.opacity(0.18))
                    .frame(height: 5)
            }
        }
    }

    private func deliveryAgo(_ days: Int) -> String {
        switch days {
        case 0: return "Hoy"
        case 1: return "Ayer"
        case 2...30: return "Hace \(days) días"
        default: return "Más de un mes"
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: "person.crop.circle.badge.questionmark",
            title: "Sin recolectores con ese filtro",
            subtitle: "Ajusta los filtros o busca por nombre para ver más resultados."
        )
    }
}

#Preview {
    RecolectoresListView()
}
