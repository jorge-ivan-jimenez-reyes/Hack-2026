import SwiftUI

/// Settings del Centro de Acopio — accesible tap en el header del Dashboard.
/// Permite editar perfil del centro, ver datos guardados, y reset.
struct CentroSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("centro.name") private var centroName = "Centro Roma Norte"
    @AppStorage("centro.zonas") private var zonasRaw = ""
    @AppStorage("centro.capacityKg") private var capacityKg = 1000
    @AppStorage("centro.daysRaw") private var daysRaw = ""

    @AppStorage("didOnboard") private var didOnboard = false
    @AppStorage("userRole") private var userRoleRaw = ""
    @AppStorage("didCompleteRoleSetup") private var didCompleteRoleSetup = false

    @State private var showResetConfirm = false

    private var zonasList: String {
        zonasRaw.isEmpty ? "Sin zonas configuradas" : zonasRaw.replacingOccurrences(of: ",", with: " · ")
    }

    private var daysList: String {
        daysRaw.isEmpty ? "Sin días configurados" : daysRaw.replacingOccurrences(of: ",", with: " · ")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.l) {
                        profileCard
                        operationsSection
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
                Text("Esto reinicia el onboarding, tu rol y la configuración del centro. No se puede deshacer.")
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
                            colors: [.clay, .clay.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "building.2.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.cream)
            }
            .frame(width: 80, height: 80)

            VStack(spacing: 2) {
                Text(centroName.isEmpty ? "Centro de acopio" : centroName)
                    .font(.appTitle2)
                    .foregroundStyle(.inkCharcoal)
                    .multilineTextAlignment(.center)
                HStack(spacing: 4) {
                    Image(systemName: "person.fill").font(.caption)
                    Text("Operador: María")
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

    private var operationsSection: some View {
        sectionCard(title: "Operación") {
            VStack(spacing: Spacing.s) {
                infoRow(
                    icon: "map.fill",
                    tint: .brand,
                    label: "Zonas que cubres",
                    value: zonasList
                )
                Divider().padding(.leading, 36)
                infoRow(
                    icon: "scalemass.fill",
                    tint: .clay,
                    label: "Capacidad mensual",
                    value: "\(capacityKg) kg"
                )
                Divider().padding(.leading, 36)
                infoRow(
                    icon: "calendar",
                    tint: .moss,
                    label: "Días de operación",
                    value: daysList
                )
            }
        }
    }

    private var dataSection: some View {
        sectionCard(title: "Datos & privacidad") {
            VStack(spacing: Spacing.s) {
                infoRow(icon: "lock.shield.fill", tint: .brand, label: "Tus datos viven en este iPhone", value: nil)
                Divider().padding(.leading, 36)
                infoRow(icon: "sparkles", tint: .info, label: "Coach IA corre on-device", value: nil)
                Divider().padding(.leading, 36)
                infoRow(icon: "person.crop.rectangle.stack.fill", tint: .moss, label: "Datos de recolectores se anonimizan al compartir", value: nil)
            }
        }
    }

    private var aboutSection: some View {
        sectionCard(title: "Sobre la app") {
            VStack(spacing: Spacing.s) {
                infoRow(icon: "info.circle.fill", tint: .clay, label: "HackNacional 2026 · v1.0.0", value: nil)
                Divider().padding(.leading, 36)
                infoRow(icon: "person.3.fill", tint: .brand, label: "Equipo: Jorge, Esteban, Mon, Iñaki", value: nil)
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

    private func infoRow(icon: String, tint: Color, label: String, value: String?) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.appBody)
                    .foregroundStyle(.inkCharcoal)
                if let value = value {
                    Text(value)
                        .font(.appCaption)
                        .foregroundStyle(.inkCharcoal.opacity(0.65))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    CentroSettingsView()
}
