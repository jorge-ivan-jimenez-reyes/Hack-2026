import SwiftUI

/// Sheet para programar la entrega de la cubeta lista. Cambia el flow según
/// la modalidad del recolector:
/// - `.pickup`  → escoger día/hora de pickup en domicilio
/// - `.dropOff` → escoger centro de acopio y horario en que va a llevarla
struct ScheduleDeliverySheet: View {
    let mode: ServiceMode
    let nearestCenter: NearestCenter?

    @Environment(\.dismiss) private var dismiss

    @State private var selectedDate = Date().addingTimeInterval(60 * 60 * 24) // mañana
    @State private var selectedHour = 9
    @State private var selectedCenter: String
    @State private var contactPhone: String = ""
    @State private var notes: String = ""
    @State private var didConfirm = false
    @State private var isConfirming = false

    /// Lista mock de centros disponibles. En prod vendría de CenterLocation.
    private let centers: [String] = [
        "Composta Roma Norte",
        "Centro Coyoacán",
        "Centro Condesa",
        "Centro Polanco"
    ]

    init(mode: ServiceMode, nearestCenter: NearestCenter?) {
        self.mode = mode
        self.nearestCenter = nearestCenter
        _selectedCenter = State(initialValue: nearestCenter?.name ?? "Composta Roma Norte")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cream.ignoresSafeArea()

                if didConfirm {
                    confirmationView
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                } else {
                    formView
                        .transition(.opacity)
                }
            }
            .navigationTitle(mode == .pickup ? "Programar pickup" : "Programar entrega")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !didConfirm {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancelar") {
                            Haptics.tap()
                            dismiss()
                        }
                        .foregroundStyle(.inkCharcoal.opacity(0.65))
                    }
                }
            }
            .animation(AppAnimation.spring, value: didConfirm)
        }
    }

    // MARK: - Form

    private var formView: some View {
        ScrollView {
            VStack(spacing: Spacing.l) {
                heroBanner
                if mode == .pickup {
                    pickupSection
                } else {
                    dropOffSection
                }
                dateTimeSection
                notesSection
                confirmButton
                Color.clear.frame(height: 40)
            }
            .padding(.vertical, Spacing.l)
        }
        .scrollIndicators(.hidden)
    }

    private var heroBanner: some View {
        HStack(spacing: Spacing.m) {
            ZStack {
                Circle()
                    .fill(Color.brand.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.brand)
                    .symbolEffect(.bounce, value: didConfirm)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Tu cubeta está lista")
                    .font(.appHeadline.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                Text(mode == .pickup ? "Te pasamos a recoger" : "Tú la llevas al centro")
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
            }
            Spacer()
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.06), radius: 10, y: 4)
        }
        .padding(.horizontal, Spacing.l)
    }

    // MARK: - Pickup

    private var pickupSection: some View {
        sectionCard(title: "Datos de contacto") {
            VStack(spacing: Spacing.s) {
                inputRow(icon: "phone.fill", placeholder: "Teléfono (opcional)", text: $contactPhone, keyboard: .phonePad)
                Divider().padding(.leading, 36)
                infoRow(icon: "house.fill", label: "Dirección", value: "Roma Norte, CDMX (de tu setup)")
            }
        }
    }

    // MARK: - Drop-off

    private var dropOffSection: some View {
        sectionCard(title: "Centro de acopio") {
            VStack(spacing: 4) {
                ForEach(centers, id: \.self) { center in
                    Button {
                        Haptics.tap()
                        selectedCenter = center
                    } label: {
                        HStack {
                            Image(systemName: selectedCenter == center ? "largecircle.fill.circle" : "circle")
                                .foregroundStyle(selectedCenter == center ? .brand : .inkCharcoal.opacity(0.35))
                                .font(.title3)
                            Text(center)
                                .font(.appBody)
                                .foregroundStyle(.inkCharcoal)
                            Spacer()
                            if center == nearestCenter?.name {
                                Text("Más cercano")
                                    .font(.appCaption.weight(.semibold))
                                    .foregroundStyle(.brand)
                                    .padding(.horizontal, Spacing.s)
                                    .padding(.vertical, 2)
                                    .background(.brand.opacity(0.15), in: .capsule)
                            }
                        }
                        .padding(.vertical, Spacing.s)
                    }
                    .buttonStyle(.plain)
                    if center != centers.last {
                        Divider()
                    }
                }
            }
        }
    }

    // MARK: - Date / time

    private var dateTimeSection: some View {
        sectionCard(title: "Fecha y hora") {
            VStack(alignment: .leading, spacing: Spacing.m) {
                DatePicker("Día", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .tint(.brand)

                Divider()

                HStack {
                    Text("Hora")
                        .font(.appBody)
                        .foregroundStyle(.inkCharcoal)
                    Spacer()
                    Picker("Hora", selection: $selectedHour) {
                        ForEach(7..<20) { h in
                            Text("\(h.padded()):00")
                                .tag(h)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.brand)
                }
            }
        }
    }

    // MARK: - Notes

    private var notesSection: some View {
        sectionCard(title: "Notas (opcional)") {
            TextField("Algo que el operador deba saber…", text: $notes, axis: .vertical)
                .font(.appBody)
                .foregroundStyle(.inkCharcoal)
                .lineLimit(2...4)
        }
    }

    // MARK: - Confirm

    private var confirmButton: some View {
        Button {
            confirmAction()
        } label: {
            HStack(spacing: Spacing.s) {
                if isConfirming {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.cream)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .transition(.scale.combined(with: .opacity))
                }
                // Texto morphea: "Confirmar" → "Programando..." → handover a confirmation view
                Text(buttonLabel)
                    .font(.appHeadline.weight(.semibold))
                    .contentTransition(.numericText())
            }
            .foregroundStyle(.cream)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(.brand, in: .capsule)
            .shadow(color: Color.brand.opacity(0.30), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.l)
        .disabled(isConfirming)
    }

    private var buttonLabel: String {
        isConfirming ? "Programando…" : "Confirmar"
    }

    private func confirmAction() {
        Haptics.tap()
        withAnimation(AppAnimation.spring) {
            isConfirming = true
        }
        // Si es pickup, dispara la Live Activity para que aparezca en
        // Lock Screen / Dynamic Island con ETA del camión.
        if mode == .pickup {
            let etaMinutes = max(5, Int(selectedDate.timeIntervalSinceNow / 60))
            PickupLiveActivityController.start(
                centroName: selectedCenter,
                address: "Roma Norte, CDMX",
                initialEtaMinutes: etaMinutes
            )
        }
        // Pequeño delay artificial para que el morph se vea — Family-style.
        Task {
            try? await Task.sleep(for: .milliseconds(550))
            await MainActor.run {
                Haptics.success()
                withAnimation(AppAnimation.spring) {
                    didConfirm = true
                    isConfirming = false
                }
            }
        }
    }

    // MARK: - Confirmation

    private var confirmationView: some View {
        VStack(spacing: Spacing.l) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.brand.opacity(0.15))
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.brand)
                    .symbolEffect(.bounce, options: .repeat(2), value: didConfirm)
            }
            VStack(spacing: Spacing.s) {
                Text("¡Listo!")
                    .font(.appLargeTitle.weight(.bold))
                    .foregroundStyle(.inkCharcoal)
                Text(confirmationMessage)
                    .font(.appBody)
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }

            VStack(alignment: .leading, spacing: Spacing.s) {
                summaryRow(icon: "calendar", label: "Día", value: selectedDate.formatted(.dateTime.weekday(.wide).day().month()))
                summaryRow(icon: "clock", label: "Hora", value: "\(selectedHour):00")
                if mode == .dropOff {
                    summaryRow(icon: "mappin.circle.fill", label: "Centro", value: selectedCenter)
                }
            }
            .padding(Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(.white)
                    .shadow(color: Color.inkCharcoal.opacity(0.06), radius: 10, y: 4)
            }
            .padding(.horizontal, Spacing.l)

            Spacer()

            Button {
                Haptics.tap()
                dismiss()
            } label: {
                Text("Volver al inicio")
                    .font(.appHeadline.weight(.semibold))
                    .foregroundStyle(.cream)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(.brand, in: .capsule)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Spacing.l)
            .padding(.bottom, Spacing.l)
        }
    }

    private var confirmationMessage: String {
        let day = selectedDate.formatted(.dateTime.weekday(.wide).day().month())
        if mode == .pickup {
            return "Te pasamos a recoger \(day) a las \(selectedHour):00."
        } else {
            return "Te esperamos en \(selectedCenter) el \(day) a las \(selectedHour):00."
        }
    }

    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundStyle(.brand)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
                Text(value)
                    .font(.appBody.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
            }
            Spacer()
        }
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

    private func inputRow(icon: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.brand)
                .frame(width: 28)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .font(.appBody)
                .foregroundStyle(.inkCharcoal)
        }
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundStyle(.brand)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
                Text(value)
                    .font(.appBody)
                    .foregroundStyle(.inkCharcoal)
            }
            Spacer()
        }
    }
}

private extension Int {
    func padded() -> String { self < 10 ? "0\(self)" : "\(self)" }
}

#Preview("Pickup") {
    ScheduleDeliverySheet(
        mode: .pickup,
        nearestCenter: nil
    )
}

#Preview("Drop-off") {
    ScheduleDeliverySheet(
        mode: .dropOff,
        nearestCenter: NearestCenter(
            name: "Composta Roma Norte",
            distanceKm: 0.4,
            nextOpeningDate: .now
        )
    )
}
