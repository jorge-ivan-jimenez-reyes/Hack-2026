import SwiftUI

/// 4 preguntas paginadas para activar el Centro. Misma arquitectura que
/// RecolectorSetupView — una pregunta por pantalla con morph + symbolEffect.
struct CentroSetupView: View {
    let onComplete: () -> Void

    @AppStorage("centro.name") private var centroName = ""
    @AppStorage("centro.zonas") private var zonasRaw = ""
    @AppStorage("centro.capacityKg") private var capacityKg = 1000
    @AppStorage("centro.daysRaw") private var daysRaw = ""

    @State private var selectedZonas: Set<String> = []
    @State private var selectedDays: Set<String> = []
    @State private var step = 0
    @Namespace private var heroNamespace

    private let totalSteps = 4

    private let alcaldias = [
        "Álvaro Obregón", "Benito Juárez", "Coyoacán", "Cuauhtémoc",
        "Iztacalco", "Iztapalapa", "Miguel Hidalgo", "Roma Norte",
        "Tláhuac", "Tlalpan", "Venustiano Carranza", "Xochimilco"
    ]

    private let weekDays = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]

    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ZStack {
                    ForEach(0..<totalSteps, id: \.self) { i in
                        if i == step {
                            stepView(for: i)
                                .transition(stepTransition)
                        }
                    }
                }
                .animation(.smooth(duration: 0.5, extraBounce: 0.05), value: step)

                Spacer(minLength: 0)

                ctaButton
                    .padding(.horizontal, Spacing.l)
                    .padding(.bottom, Spacing.l)
            }
        }
        .onAppear {
            selectedZonas = Set(zonasRaw.split(separator: ",").map(String.init))
            selectedDays = Set(daysRaw.split(separator: ",").map(String.init))
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            if step > 0 {
                Button {
                    Haptics.tap()
                    withAnimation(.smooth(duration: 0.5, extraBounce: 0.05)) {
                        step -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.inkCharcoal)
                        .frame(width: 36, height: 36)
                        .glassEffect(.regular.tint(.inkCharcoal.opacity(0.06)).interactive(), in: .circle)
                }
            } else {
                Color.clear.frame(width: 36, height: 36)
            }

            ProgressBar(current: step, total: totalSteps, namespace: heroNamespace)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Spacing.s)

            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
        .frame(height: 56)
    }

    private var stepTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    // MARK: - Steps

    @ViewBuilder
    private func stepView(for index: Int) -> some View {
        switch index {
        case 0: nameStep
        case 1: zonasStep
        case 2: capacityStep
        case 3: daysStep
        default: EmptyView()
        }
    }

    private var nameStep: some View {
        StepContainer(
            symbol: "building.2.fill",
            title: "¿Cuál es el nombre del centro?",
            subtitle: "Tus recolectores lo verán en la app."
        ) {
            TextField("Ej. Composta Roma Norte", text: $centroName)
                .textFieldStyle(.plain)
                .font(.appTitle2)
                .foregroundStyle(.inkCharcoal)
                .multilineTextAlignment(.center)
                .padding(Spacing.l)
                .background {
                    RoundedRectangle(cornerRadius: Radius.l)
                        .fill(.white)
                        .shadow(color: Color.inkCharcoal.opacity(0.06), radius: 10, y: 4)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: Radius.l)
                        .stroke(Color.brand.opacity(0.20), lineWidth: 1)
                }
        }
    }

    private var zonasStep: some View {
        StepContainer(
            symbol: "map.fill",
            title: "¿Qué zonas cubres?",
            subtitle: "Selecciona todas las que apliquen."
        ) {
            FlowLayout(spacing: 8) {
                ForEach(alcaldias, id: \.self) { zona in
                    zonaChip(zona)
                }
            }
        }
    }

    private func zonaChip(_ zona: String) -> some View {
        let selected = selectedZonas.contains(zona)
        return Button {
            Haptics.tap()
            withAnimation(.snappy(duration: 0.25)) {
                if selected {
                    selectedZonas.remove(zona)
                } else {
                    selectedZonas.insert(zona)
                }
            }
            zonasRaw = selectedZonas.sorted().joined(separator: ",")
        } label: {
            Text(zona)
                .font(.appCaption.weight(.medium))
                .foregroundStyle(selected ? Color.cream : .inkCharcoal)
                .padding(.horizontal, Spacing.m)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(selected ? Color.brand : .white)
                        .shadow(
                            color: selected ? Color.brand.opacity(0.20) : Color.inkCharcoal.opacity(0.05),
                            radius: selected ? 8 : 3,
                            y: 2
                        )
                }
                .overlay {
                    Capsule()
                        .stroke(Color.inkCharcoal.opacity(selected ? 0 : 0.10), lineWidth: 1)
                }
                .scaleEffect(selected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }

    private var capacityStep: some View {
        StepContainer(
            symbol: "scalemass.fill",
            title: "¿Capacidad mensual?",
            subtitle: "Estimado en kg de orgánico procesado."
        ) {
            VStack(spacing: Spacing.l) {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(capacityKg)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(.inkCharcoal)
                        .contentTransition(.numericText(value: Double(capacityKg)))
                    Text("kg")
                        .font(.appTitle2)
                        .foregroundStyle(.inkCharcoal.opacity(0.55))
                }
                Slider(
                    value: Binding(
                        get: { Double(capacityKg) },
                        set: { capacityKg = Int($0) }
                    ),
                    in: 100...5000,
                    step: 100
                )
                .tint(.brand)
                .padding(.horizontal, Spacing.l)
            }
        }
    }

    private var daysStep: some View {
        StepContainer(
            symbol: "calendar",
            title: "¿Días de operación?",
            subtitle: "Toca los días que abres."
        ) {
            HStack(spacing: 6) {
                ForEach(weekDays, id: \.self) { day in
                    dayChip(day)
                }
            }
        }
    }

    private func dayChip(_ day: String) -> some View {
        let selected = selectedDays.contains(day)
        return Button {
            Haptics.tap()
            withAnimation(.snappy(duration: 0.25)) {
                if selected {
                    selectedDays.remove(day)
                } else {
                    selectedDays.insert(day)
                }
            }
            daysRaw = selectedDays.sorted().joined(separator: ",")
        } label: {
            Text(day)
                .font(.appCallout.weight(.semibold))
                .foregroundStyle(selected ? Color.cream : .inkCharcoal)
                .frame(width: 44, height: 44)
                .background {
                    Circle()
                        .fill(selected ? Color.brand : .white)
                        .shadow(
                            color: selected ? Color.brand.opacity(0.20) : Color.inkCharcoal.opacity(0.05),
                            radius: selected ? 8 : 3,
                            y: 2
                        )
                }
                .overlay {
                    Circle()
                        .stroke(Color.inkCharcoal.opacity(selected ? 0 : 0.10), lineWidth: 1)
                }
                .scaleEffect(selected ? 1.10 : 1.0)
        }
        .buttonStyle(.plain)
    }

    // MARK: - CTA

    private var ctaButton: some View {
        let isLast = step == totalSteps - 1
        let canContinue = stepIsValid(step)

        return Button {
            guard canContinue else { return }
            if isLast {
                Haptics.success()
                onComplete()
            } else {
                Haptics.tap()
                withAnimation(.smooth(duration: 0.5, extraBounce: 0.05)) {
                    step += 1
                }
            }
        } label: {
            HStack(spacing: Spacing.s) {
                Text(isLast ? "Activar mi centro" : "Continuar")
                    .font(.appHeadline.weight(.semibold))
                    .contentTransition(.opacity)
                Image(systemName: isLast ? "checkmark.circle.fill" : "arrow.right")
                    .symbolEffect(.bounce, value: step)
            }
            .foregroundStyle(.cream)
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, Spacing.l)
            .glassEffect(
                .regular.tint(Color.brand.opacity(canContinue ? 0.95 : 0.4)).interactive(),
                in: .capsule
            )
            .shadow(color: Color.brand.opacity(canContinue ? 0.20 : 0), radius: 16, y: 6)
        }
        .disabled(!canContinue)
    }

    private func stepIsValid(_ step: Int) -> Bool {
        switch step {
        case 0: return !centroName.isEmpty
        case 1: return !selectedZonas.isEmpty
        case 2: return capacityKg > 0
        case 3: return !selectedDays.isEmpty
        default: return true
        }
    }
}

/// FlowLayout — layout custom para chips que wrappean. Reusado de iOS 16+ Layout.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var totalHeight: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width + spacing > maxWidth {
                totalHeight += rowHeight + spacing
                rowWidth = size.width + spacing
                rowHeight = size.height
            } else {
                rowWidth += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    CentroSetupView { print("done") }
}
