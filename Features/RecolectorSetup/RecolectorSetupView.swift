import SwiftUI

/// 5 preguntas paginadas — una por pantalla, con hero icon grande, symbolEffect
/// al cambiar paso, transiciones blurReplace + slide, progress bar arriba.
/// Apple Health DNA — cada pregunta tiene su momento.
struct RecolectorSetupView: View {
    let onComplete: () -> Void

    @AppStorage("recolector.alcaldia") private var alcaldia = "Roma Norte"
    @AppStorage("recolector.householdSize") private var householdSize = 2
    @AppStorage("recolector.experience") private var experience = "first_time"
    @AppStorage("recolector.hasGarden") private var hasGarden = false
    /// Modalidad: "pickup" (paid, pasamos a domicilio) o "drop_off" (free, lleva al centro).
    @AppStorage("recolector.serviceMode") private var serviceMode = "drop_off"

    @State private var step = 0
    @Namespace private var heroNamespace

    private let totalSteps = 5

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
    }

    // MARK: - Top bar (progress)

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
        case 0: alcaldiaStep
        case 1: householdStep
        case 2: experienceStep
        case 3: gardenStep
        case 4: serviceModeStep
        default: EmptyView()
        }
    }

    private var alcaldiaStep: some View {
        StepContainer(
            symbol: "mappin.and.ellipse",
            title: "¿En qué alcaldía vives?",
            subtitle: "Te mostraremos centros cercanos a ti."
        ) {
            Picker("Alcaldía", selection: $alcaldia) {
                ForEach(alcaldias, id: \.self) { a in
                    Text(a).tag(a)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 180)
        }
    }

    private var householdStep: some View {
        StepContainer(
            symbol: "person.3.fill",
            title: "¿Cuántas personas viven contigo?",
            subtitle: "Calibramos el volumen estimado de tu cubeta."
        ) {
            HStack(spacing: Spacing.l) {
                Button {
                    Haptics.tap()
                    if householdSize > 1 { householdSize -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.brand)
                        .frame(width: 56, height: 56)
                        .background(Color.brand.opacity(0.12), in: .circle)
                }
                .buttonStyle(.plain)
                .disabled(householdSize <= 1)

                Text("\(householdSize)")
                    .font(.system(size: 84, weight: .bold, design: .rounded))
                    .foregroundStyle(.inkCharcoal)
                    .frame(width: 120)
                    .contentTransition(.numericText(value: Double(householdSize)))

                Button {
                    Haptics.tap()
                    if householdSize < 8 { householdSize += 1 }
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.brand)
                        .frame(width: 56, height: 56)
                        .background(Color.brand.opacity(0.12), in: .circle)
                }
                .buttonStyle(.plain)
                .disabled(householdSize >= 8)
            }
        }
    }

    private var experienceStep: some View {
        StepContainer(
            symbol: "leaf.fill",
            title: "¿Ya separas tu orgánico?",
            subtitle: "Calibramos el tono de tu Coach IA."
        ) {
            VStack(spacing: Spacing.s) {
                radioOption(value: "always", label: "Sí, siempre", subtitle: "Soy pro", binding: $experience)
                radioOption(value: "sometimes", label: "A veces", subtitle: "Cuando me acuerdo", binding: $experience)
                radioOption(value: "first_time", label: "Apenas empiezo", subtitle: "Quiero aprender", binding: $experience)
            }
        }
    }

    private var gardenStep: some View {
        StepContainer(
            symbol: "tree.fill",
            title: "¿Tienes plantas o jardín?",
            subtitle: "Define si entregamos tu abono físico."
        ) {
            HStack(spacing: Spacing.m) {
                yesNoCard(value: true, label: "Sí, tengo", icon: "checkmark.circle.fill")
                yesNoCard(value: false, label: "Aún no", icon: "minus.circle")
            }
        }
    }

    private var serviceModeStep: some View {
        StepContainer(
            symbol: "shippingbox.and.arrow.backward.fill",
            title: "¿Cómo entregas tu cubeta?",
            subtitle: "Puedes cambiar de modalidad después."
        ) {
            VStack(spacing: Spacing.m) {
                serviceModeCard(
                    value: "drop_off",
                    icon: "mappin.circle.fill",
                    label: "Yo la llevo al centro",
                    subtitle: "Gratis. Te avisamos cuándo abren los centros cercanos."
                )
                serviceModeCard(
                    value: "pickup",
                    icon: "shippingbox.fill",
                    label: "Pasen por mi cubeta",
                    subtitle: "Suscripción. Pasamos a domicilio el día que prefieras."
                )
            }
        }
    }

    private func serviceModeCard(value: String, icon: String, label: String, subtitle: String) -> some View {
        let selected = (serviceMode == value)
        return Button {
            Haptics.tap()
            withAnimation(.snappy(duration: 0.25)) {
                serviceMode = value
            }
        } label: {
            HStack(alignment: .top, spacing: Spacing.m) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(selected ? .brand : .inkCharcoal.opacity(0.40))
                    .symbolEffect(.bounce, value: selected)
                    .frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(label)
                            .font(.appHeadline.weight(.semibold))
                            .foregroundStyle(.inkCharcoal)
                        Spacer()
                        if value == "drop_off" {
                            tag(text: "Gratis", tint: .brand)
                        } else {
                            tag(text: "Suscripción", tint: .clay)
                        }
                    }
                    Text(subtitle)
                        .font(.appCallout)
                        .foregroundStyle(.inkCharcoal.opacity(0.65))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(selected ? Color.brand.opacity(0.10) : Color.white)
                    .shadow(
                        color: selected ? Color.brand.opacity(0.14) : Color.inkCharcoal.opacity(0.04),
                        radius: selected ? 12 : 6,
                        y: selected ? 4 : 2
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: Radius.l)
                    .stroke(selected ? Color.brand.opacity(0.40) : Color.clear, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }

    private func tag(text: String, tint: Color) -> some View {
        Text(text)
            .font(.appCaption.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, 3)
            .background(tint.opacity(0.15), in: .capsule)
    }

    // MARK: - Reusable inputs

    private func radioOption(value: String, label: String, subtitle: String, binding: Binding<String>) -> some View {
        let selected = (binding.wrappedValue == value)
        return Button {
            Haptics.tap()
            withAnimation(.snappy(duration: 0.25)) {
                binding.wrappedValue = value
            }
        } label: {
            HStack(spacing: Spacing.m) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(selected ? .brand : .inkCharcoal.opacity(0.30))
                    .symbolEffect(.bounce, value: selected)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.appBody.weight(.semibold))
                        .foregroundStyle(.inkCharcoal)
                    Text(subtitle)
                        .font(.appCaption)
                        .foregroundStyle(.inkCharcoal.opacity(0.55))
                }
                Spacer()
            }
            .padding(Spacing.m)
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(selected ? Color.brand.opacity(0.10) : Color.white)
                    .shadow(
                        color: selected ? Color.brand.opacity(0.14) : Color.inkCharcoal.opacity(0.04),
                        radius: selected ? 12 : 6,
                        y: selected ? 4 : 2
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: Radius.l)
                    .stroke(selected ? Color.brand.opacity(0.40) : Color.clear, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }

    private func yesNoCard(value: Bool, label: String, icon: String) -> some View {
        let selected = (hasGarden == value)
        return Button {
            Haptics.tap()
            withAnimation(.snappy(duration: 0.25)) {
                hasGarden = value
            }
        } label: {
            VStack(spacing: Spacing.m) {
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(selected ? .brand : .inkCharcoal.opacity(0.40))
                    .symbolEffect(.bounce, value: selected)
                Text(label)
                    .font(.appHeadline.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xl)
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(selected ? Color.brand.opacity(0.10) : Color.white)
                    .shadow(
                        color: selected ? Color.brand.opacity(0.14) : Color.inkCharcoal.opacity(0.04),
                        radius: selected ? 12 : 6,
                        y: selected ? 4 : 2
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: Radius.l)
                    .stroke(selected ? Color.brand.opacity(0.40) : Color.clear, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - CTA

    private var ctaButton: some View {
        let isLast = step == totalSteps - 1
        return Button {
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
                Text(isLast ? "Configurar mi cuenta" : "Continuar")
                    .font(.appHeadline.weight(.semibold))
                    .contentTransition(.opacity)
                Image(systemName: isLast ? "checkmark.circle.fill" : "arrow.right")
                    .symbolEffect(.bounce, value: step)
            }
            .foregroundStyle(.cream)
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, Spacing.l)
            .glassEffect(
                .regular.tint(Color.brand.opacity(0.95)).interactive(),
                in: .capsule
            )
            .shadow(color: Color.brand.opacity(0.20), radius: 16, y: 6)
        }
    }

    private let alcaldias = [
        "Álvaro Obregón", "Azcapotzalco", "Benito Juárez", "Coyoacán",
        "Cuajimalpa", "Cuauhtémoc", "Gustavo A. Madero", "Iztacalco",
        "Iztapalapa", "Magdalena Contreras", "Miguel Hidalgo", "Milpa Alta",
        "Roma Norte", "Tláhuac", "Tlalpan", "Venustiano Carranza", "Xochimilco"
    ]
}

/// Layout standard de cada step: hero symbol grande, título, subtítulo, input.
/// Anima la entrada del hero con symbolEffect + scale.
struct StepContainer<Input: View>: View {
    let symbol: String
    let title: String
    let subtitle: String
    @ViewBuilder let input: () -> Input

    @State private var heroBounce: Int = 0

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer(minLength: 12)

            // Hero symbol gigante
            Image(systemName: symbol)
                .font(.system(size: 72, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.brand, .brand.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .symbolEffect(.bounce, value: heroBounce)
                .frame(height: 100)

            // Title + subtitle
            VStack(spacing: Spacing.s) {
                Text(title)
                    .font(.appLargeTitle)
                    .foregroundStyle(.inkCharcoal)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.appBody)
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Spacing.xl)

            // Input
            input()
                .padding(.horizontal, Spacing.l)

            Spacer(minLength: 0)
        }
        .onAppear {
            heroBounce += 1
        }
    }
}

/// Progress bar que se llena conforme avanza el step. Animation smooth Apple.
struct ProgressBar: View {
    let current: Int
    let total: Int
    let namespace: Namespace.ID

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.inkCharcoal.opacity(0.08))
                    .frame(height: 6)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.brand, .brand.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(8, geo.size.width * progress),
                        height: 6
                    )
                    .matchedGeometryEffect(id: "progress-fill", in: namespace)
            }
        }
        .frame(height: 6)
        .accessibilityLabel("Paso \(current + 1) de \(total)")
    }

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(current + 1) / Double(total)
    }
}

#Preview {
    RecolectorSetupView { print("done") }
}
