import SwiftUI

/// Pantalla que el usuario ve después del onboarding educativo.
/// Pregunta si es Recolector o Centro de acopio. Cada uno tiene su propio
/// flujo de setup específico después de aquí.
struct ProfileSelectionView: View {
    let onSelect: (UserRole) -> Void

    @State private var hovered: UserRole?
    @State private var titleOpacity: Double = 0
    @State private var cardsOffset: CGFloat = 24
    @State private var cardsOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer(minLength: 40)

                header
                    .opacity(titleOpacity)

                Spacer(minLength: 0)

                VStack(spacing: Spacing.l) {
                    roleCard(.recolector)
                    roleCard(.centro)
                }
                .padding(.horizontal, Spacing.l)
                .offset(y: cardsOffset)
                .opacity(cardsOpacity)

                Spacer(minLength: 24)
            }
        }
        .onAppear { play() }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: Spacing.s) {
            Text("¿Cómo vas a participar?")
                .font(.appLargeTitle)
                .foregroundStyle(.inkCharcoal)
                .multilineTextAlignment(.center)
            Text("Escoge tu rol para personalizar tu experiencia.")
                .font(.appBody)
                .foregroundStyle(.inkCharcoal.opacity(0.65))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, Spacing.xl)
    }

    private func roleCard(_ role: UserRole) -> some View {
        Button {
            Haptics.confirm()
            onSelect(role)
        } label: {
            HStack(alignment: .top, spacing: Spacing.l) {
                ZStack {
                    Circle()
                        .fill(role.tint.opacity(0.15))
                    Image(systemName: role.symbol)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(role.tint)
                }
                .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 6) {
                    Text(role.displayName)
                        .font(.appHeadline.weight(.semibold))
                        .foregroundStyle(.inkCharcoal)
                    Text(role.copy)
                        .font(.appCallout)
                        .foregroundStyle(.inkCharcoal.opacity(0.65))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: "arrow.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(role.tint)
            }
            .padding(Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .fill(.white)
                    .shadow(color: role.tint.opacity(0.10), radius: 18, y: 8)
            }
            .overlay {
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .stroke(role.tint.opacity(0.15), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(role.displayName). \(role.copy)")
    }

    // MARK: - Animation

    private func play() {
        withAnimation(.smooth(duration: 0.55, extraBounce: 0.05).delay(0.10)) {
            titleOpacity = 1
        }
        withAnimation(.smooth(duration: 0.55, extraBounce: 0.05).delay(0.25)) {
            cardsOffset = 0
            cardsOpacity = 1
        }
    }
}

private extension UserRole {
    var symbol: String {
        switch self {
        case .recolector: return "house.fill"
        case .centro:     return "building.2.fill"
        }
    }

    var tint: Color {
        switch self {
        case .recolector: return .brand
        case .centro:     return .clay
        }
    }

    var copy: String {
        switch self {
        case .recolector:
            return "Separas tu orgánico en casa. Pasamos por tu cubeta y recibes abono real cada 15 entregas."
        case .centro:
            return "Recibes cubetas, produces abono y lo regresas a tus recolectores. Reemplaza tu libreta de papel."
        }
    }
}

#Preview {
    ProfileSelectionView { role in
        print("Selected: \(role)")
    }
}
