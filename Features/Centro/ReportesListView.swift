import SwiftUI

/// Lista de reportes ciudadanos. Filtros por status, badge según prioridad,
/// tap → sheet con detalle + acciones (resolver, contactar).
struct ReportesListView: View {
    @State private var filter: ReporteFilter = .open
    @State private var reportes: [Reporte] = Reporte.mock
    @State private var selected: Reporte?

    private var filtered: [Reporte] {
        filter.apply(to: reportes)
    }

    private var openCount: Int {
        reportes.filter { $0.status == .open }.count
    }

    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.l) {
                    header
                    filtersRow
                    listSection
                    Color.clear.frame(height: 80)
                }
                .padding(.vertical, Spacing.s)
            }
            .scrollIndicators(.hidden)
        }
        .sheet(item: $selected) { r in
            reporteDetailSheet(r)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Reportes")
                    .font(.appTitle2)
                    .foregroundStyle(.inkCharcoal)
                HStack(spacing: 6) {
                    if openCount > 0 {
                        Circle().fill(.warning).frame(width: 8, height: 8)
                            .overlay(Circle().fill(.warning).frame(width: 8, height: 8).opacity(0.4).scaleEffect(2.2))
                    }
                    Text("\(openCount) abiertos · \(reportes.count) total")
                        .font(.appCallout)
                        .foregroundStyle(.inkCharcoal.opacity(0.65))
                }
            }
            Spacer()
            Image(systemName: "exclamationmark.bubble.fill")
                .font(.system(size: 28))
                .foregroundStyle(.warning)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
    }

    private var filtersRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ReporteFilter.allCases) { f in
                    filterChip(f)
                }
            }
            .padding(.horizontal, Spacing.l)
        }
    }

    private func filterChip(_ f: ReporteFilter) -> some View {
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

    @ViewBuilder
    private var listSection: some View {
        if filtered.isEmpty {
            emptyState
        } else {
            VStack(spacing: Spacing.s) {
                ForEach(filtered) { r in
                    reporteRow(r)
                }
            }
            .padding(.horizontal, Spacing.l)
        }
    }

    private func reporteRow(_ r: Reporte) -> some View {
        Button {
            Haptics.tap()
            selected = r
        } label: {
            HStack(spacing: Spacing.m) {
                ZStack {
                    Circle()
                        .fill(statusTint(r.status).opacity(0.18))
                    Image(systemName: r.kind.symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(statusTint(r.status))
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(r.kind.label)
                            .font(.appBody.weight(.semibold))
                            .foregroundStyle(.inkCharcoal)
                        Spacer()
                        statusBadge(r.status)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "mappin").font(.caption2)
                        Text(r.location)
                        Text("·")
                        Image(systemName: "person.fill").font(.caption2)
                        Text(r.reporterName)
                    }
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
                    .lineLimit(1)

                    Text(r.detail)
                        .font(.appCaption)
                        .foregroundStyle(.inkCharcoal.opacity(0.70))
                        .lineLimit(2)
                        .padding(.top, 2)

                    Text(timeAgo(r.hoursAgo))
                        .font(.appCaption)
                        .foregroundStyle(.inkCharcoal.opacity(0.45))
                        .padding(.top, 2)
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
        .buttonStyle(.plain)
    }

    private func statusBadge(_ s: ReporteStatus) -> some View {
        let tint = statusTint(s)
        return HStack(spacing: 4) {
            Image(systemName: s.symbol).font(.caption2)
            Text(s.rawValue).font(.appCaption.weight(.semibold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, Spacing.s)
        .padding(.vertical, 3)
        .background(tint.opacity(0.15), in: .capsule)
    }

    private func statusTint(_ s: ReporteStatus) -> Color {
        switch s {
        case .open:       return .warning
        case .inProgress: return .info
        case .resolved:   return .brand
        }
    }

    private func timeAgo(_ hours: Int) -> String {
        switch hours {
        case 0:        return "Justo ahora"
        case 1:        return "Hace 1 hora"
        case 2...23:   return "Hace \(hours) horas"
        case 24...47:  return "Hace 1 día"
        default:       return "Hace \(hours / 24) días"
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.s) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.brand)
            Text("Todo en orden")
                .font(.appHeadline.weight(.semibold))
                .foregroundStyle(.inkCharcoal)
            Text("Sin reportes pendientes en este filtro.")
                .font(.appCallout)
                .foregroundStyle(.inkCharcoal.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
    }

    // MARK: - Detail sheet

    @ViewBuilder
    private func reporteDetailSheet(_ r: Reporte) -> some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            HStack(alignment: .top, spacing: Spacing.m) {
                ZStack {
                    Circle().fill(statusTint(r.status).opacity(0.18))
                    Image(systemName: r.kind.symbol)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(statusTint(r.status))
                }
                .frame(width: 60, height: 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text(r.kind.label)
                        .font(.appTitle2.weight(.bold))
                        .foregroundStyle(.inkCharcoal)
                    Text("\(r.location) · \(r.reporterName)")
                        .font(.appCallout)
                        .foregroundStyle(.inkCharcoal.opacity(0.65))
                }
                Spacer()
            }

            Text(r.detail)
                .font(.appBody)
                .foregroundStyle(.inkCharcoal)
                .padding(Spacing.m)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: Radius.m)
                        .fill(Color.cream)
                }

            HStack(spacing: Spacing.s) {
                actionButton(label: "Marcar resuelto", icon: "checkmark.circle.fill", color: .brand) {
                    updateStatus(r, to: .resolved)
                }
                actionButton(label: "Contactar", icon: "phone.fill", color: .info) {
                    Haptics.tap()
                }
            }

            Spacer()
        }
        .padding(Spacing.l)
        .background(Color.cream)
    }

    private func actionButton(label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.body.weight(.semibold))
                Text(label).font(.appBody.weight(.semibold))
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(color.opacity(0.15), in: .capsule)
            .overlay(Capsule().stroke(color.opacity(0.30), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    private func updateStatus(_ r: Reporte, to status: ReporteStatus) {
        Haptics.success()
        if let idx = reportes.firstIndex(of: r) {
            withAnimation(.smooth(duration: 0.4)) {
                reportes[idx].status = status
            }
        }
        selected = nil
    }
}

#Preview {
    ReportesListView()
}
