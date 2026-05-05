import SwiftUI

/// Settings del Recolector — accesible tap en el header del Home.
/// Permite editar perfil, cambiar modalidad de servicio, ver datos y reset.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("recolector.alcaldia") private var alcaldia = "Roma Norte"
    @AppStorage("recolector.householdSize") private var householdSize = 2
    @AppStorage("recolector.hasGarden") private var hasGarden = false
    @AppStorage("recolector.serviceMode") private var serviceMode = "drop_off"

    @AppStorage("didOnboard") private var didOnboard = false
    @AppStorage("userRole") private var userRoleRaw = ""
    @AppStorage("didCompleteRoleSetup") private var didCompleteRoleSetup = false

    @State private var showModalitySheet = false
    @State private var showResetConfirm = false

    private var modalityIsPickup: Bool { serviceMode == "pickup" }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.l) {
                        profileCard
                        modalitySection
                        householdSection
                        dataSection
                        aboutSection
                        resetSection
                        Color.clear.frame(height: 40)
                    }
                    .padding(.vertical, Spacing.l)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") {
                        Haptics.tap()
                        dismiss()
                    }
                    .font(.appBody.weight(.semibold))
                    .foregroundStyle(.brand)
                }
            }
            .sheet(isPresented: $showModalitySheet) {
                ChangeModalitySheet(serviceMode: $serviceMode)
                    .presentationDetents([.height(440)])
                    .presentationDragIndicator(.visible)
            }
            .confirmationDialog(
                "¿Borrar todo y empezar de nuevo?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Borrar y reiniciar", role: .destructive) {
                    didOnboard = false
                    userRoleRaw = ""
                    didCompleteRoleSetup = false
                    Haptics.warning()
                    dismiss()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Esto reinicia el onboarding, tu rol y todas las preguntas. No se puede deshacer.")
            }
        }
    }

    // MARK: - Sections

    private var profileCard: some View {
        VStack(spacing: Spacing.m) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.brand, .brand.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("J")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.cream)
            }
            .frame(width: 80, height: 80)

            VStack(spacing: 2) {
                Text("Jorge Jiménez")
                    .font(.appTitle2)
                    .foregroundStyle(.inkCharcoal)
                HStack(spacing: 4) {
                    Image(systemName: "mappin").font(.caption)
                    Text(alcaldia)
                        .font(.appCallout)
                }
                .foregroundStyle(.inkCharcoal.opacity(0.65))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.l)
        .padding(.horizontal, Spacing.l)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 8, y: 3)
        }
        .padding(.horizontal, Spacing.l)
    }

    private var modalitySection: some View {
        sectionCard(title: "Modalidad de servicio") {
            Button {
                Haptics.tap()
                showModalitySheet = true
            } label: {
                HStack(spacing: Spacing.m) {
                    ZStack {
                        Circle().fill((modalityIsPickup ? Color.clay : Color.brand).opacity(0.15))
                        Image(systemName: modalityIsPickup ? "shippingbox.fill" : "mappin.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(modalityIsPickup ? .clay : .brand)
                    }
                    .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(modalityIsPickup ? "Pickup a domicilio" : "Llevo al centro")
                            .font(.appBody.weight(.semibold))
                            .foregroundStyle(.inkCharcoal)
                        Text(modalityIsPickup ? "Suscripción" : "Gratis")
                            .font(.appCaption)
                            .foregroundStyle(.inkCharcoal.opacity(0.55))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.inkCharcoal.opacity(0.30))
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var householdSection: some View {
        sectionCard(title: "Tu hogar") {
            VStack(spacing: Spacing.s) {
                HStack {
                    Image(systemName: "person.3.fill").foregroundStyle(.brand).frame(width: 28)
                    Text("Personas en tu hogar")
                        .font(.appBody)
                        .foregroundStyle(.inkCharcoal)
                    Spacer()
                    Text("\(householdSize)")
                        .font(.appBody.weight(.semibold))
                        .foregroundStyle(.inkCharcoal)
                        .contentTransition(.numericText(value: Double(householdSize)))
                    Stepper("", value: $householdSize, in: 1...8)
                        .labelsHidden()
                        .scaleEffect(0.9)
                        .tint(.brand)
                }
                Divider().padding(.leading, 36)
                Toggle(isOn: $hasGarden) {
                    HStack {
                        Image(systemName: "tree.fill").foregroundStyle(.moss).frame(width: 28)
                        Text("Tienes plantas o jardín")
                            .font(.appBody)
                            .foregroundStyle(.inkCharcoal)
                    }
                }
                .tint(.brand)
            }
        }
    }

    private var dataSection: some View {
        sectionCard(title: "Datos & privacidad") {
            VStack(spacing: Spacing.s) {
                infoRow(icon: "lock.shield.fill", tint: .brand, label: "Tus datos viven en tu iPhone")
                Divider().padding(.leading, 36)
                infoRow(icon: "sparkles", tint: .info, label: "Coach IA corre on-device")
                Divider().padding(.leading, 36)
                infoRow(icon: "leaf.fill", tint: .moss, label: "Solo compartimos kg agregados con tu cuadra")
            }
        }
    }

    private var aboutSection: some View {
        sectionCard(title: "Sobre la app") {
            VStack(spacing: Spacing.s) {
                infoRow(icon: "info.circle.fill", tint: .clay, label: "HackNacional 2026 · v1.0.0")
                Divider().padding(.leading, 36)
                infoRow(icon: "person.3.fill", tint: .brand, label: "Equipo: Jorge, Esteban, Mon, Iñaki")
            }
        }
    }

    private var resetSection: some View {
        Button {
            Haptics.tap()
            showResetConfirm = true
        } label: {
            HStack {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                Text("Empezar de nuevo")
                    .font(.appBody.weight(.semibold))
            }
            .foregroundStyle(.danger)
            .frame(maxWidth: .infinity)
            .padding(Spacing.m)
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(Color.danger.opacity(0.10))
            }
            .overlay {
                RoundedRectangle(cornerRadius: Radius.l)
                    .stroke(Color.danger.opacity(0.30), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.l)
    }

    // MARK: - Helpers

    private func sectionCard<C: View>(title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(title)
                .font(.appCallout.weight(.semibold))
                .foregroundStyle(.inkCharcoal.opacity(0.55))
                .textCase(.uppercase)
                .padding(.horizontal, Spacing.s)

            content()
                .padding(Spacing.l)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: Radius.l)
                        .fill(.white)
                        .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 8, y: 3)
                }
        }
        .padding(.horizontal, Spacing.l)
    }

    private func infoRow(icon: String, tint: Color, label: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .frame(width: 28)
            Text(label)
                .font(.appBody)
                .foregroundStyle(.inkCharcoal)
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}
