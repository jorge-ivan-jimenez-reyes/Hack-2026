import SwiftUI

struct ScannerView: View {
    @State private var coordinator = ScannerCoordinator()
    @State private var rippleTrigger = 0

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Escanear")
                .navigationBarTitleDisplayMode(.inline)
        }
        .task { await coordinator.startCamera() }
        .onDisappear { coordinator.stopCamera() }
    }

    @ViewBuilder
    private var content: some View {
        switch coordinator.state {
        case .idle, .capturing, .classifying, .explaining:
            cameraStage
        case .explained(let classification, let response, let image):
            ResultView(
                image: image,
                classification: classification,
                response: response,
                onDone: { coordinator.reset() }
            )
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.96)),
                removal: .opacity
            ))
        case .error(let msg):
            errorView(msg)
        }
    }

    private var cameraStage: some View {
        ZStack(alignment: .bottom) {
            cameraLayer
                .ignoresSafeArea()

            // Overlay con scan line mientras la IA trabaja
            if isWorking {
                ScanLineEffect(color: .brand)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            captureControls
        }
        .background(Color.black)
        .animation(AppAnimation.smooth, value: isWorking)
    }

    @ViewBuilder
    private var cameraLayer: some View {
        switch coordinator.camera.status {
        case .running, .paused:
            // Paused = la session está pausada pero el layer sigue attachado.
            // Mostramos el preview siempre que esté configurado para evitar
            // el flicker al re-entrar al sheet.
            CameraPreview(session: coordinator.camera.session)
        case .denied:
            permissionDeniedView
        case .configuring, .idle:
            ProgressView("Iniciando cámara…")
                .tint(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let m):
            errorView(m)
        }
    }

    private var captureControls: some View {
        VStack(spacing: Spacing.m) {
            statusPill
                .animation(AppAnimation.spring, value: stateKey)
            captureButton
        }
        .padding(.bottom, Spacing.xxl)
    }

    @ViewBuilder
    private var statusPill: some View {
        switch coordinator.state {
        case .classifying:
            statusText("Clasificando…", systemImage: "sparkles", animateSymbol: true)
                .transition(.scale.combined(with: .opacity))
        case .explaining:
            statusText("Generando explicación…", systemImage: "text.bubble.fill", animateSymbol: true)
                .transition(.scale.combined(with: .opacity))
        case .capturing:
            statusText("Capturando…", systemImage: "camera.fill", animateSymbol: false)
                .transition(.scale.combined(with: .opacity))
        default:
            EmptyView()
        }
    }

    private func statusText(_ text: String, systemImage: String, animateSymbol: Bool) -> some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: systemImage)
                .symbolEffect(.variableColor.iterative, isActive: animateSymbol)
            Text(text)
        }
        .font(.appCallout)
        .padding(.horizontal, Spacing.l)
        .padding(.vertical, Spacing.s)
        .glassEffect(.regular, in: .rect(cornerRadius: Radius.pill))
    }

    private var captureButton: some View {
        Button {
            Haptics.confirm()
            rippleTrigger += 1
            Task { await coordinator.captureAndClassify() }
        } label: {
            ZStack {
                // Ripple — 3 anillos concéntricos que se expanden y desvanecen
                // al tap. Patrón Family-style: feedback espacial que conecta
                // la acción con el efecto.
                CaptureRipple(trigger: rippleTrigger)
                    .allowsHitTesting(false)

                Circle()
                    .stroke(.white, lineWidth: 4)
                    .frame(width: 84, height: 84)
                Circle()
                    .fill(.white)
                    .frame(width: 72, height: 72)
                    .scaleEffect(isWorking ? 0.7 : 1)
                    .animation(AppAnimation.spring, value: isWorking)
                if isWorking {
                    ProgressView()
                        .controlSize(.regular)
                        .tint(.black)
                }
            }
        }
        .disabled(!isReady)
        .accessibilityLabel("Capturar foto")
        .accessibilityHint("Toma una foto del residuo para clasificarlo")
    }

    private var isReady: Bool {
        if case .running = coordinator.camera.status,
           case .idle = coordinator.state { return true }
        return false
    }

    private var isWorking: Bool {
        switch coordinator.state {
        case .capturing, .classifying, .explaining: true
        default: false
        }
    }

    /// Identificador estable del estado para que `animation(_:value:)` lo detecte.
    private var stateKey: String {
        switch coordinator.state {
        case .idle: "idle"
        case .capturing: "capturing"
        case .classifying: "classifying"
        case .explaining: "explaining"
        case .explained: "explained"
        case .error: "error"
        }
    }

    private var permissionDeniedView: some View {
        VStack(spacing: Spacing.l) {
            Image(systemName: "camera.fill")
                .font(.largeTitle)
                .symbolEffect(.bounce, options: .repeat(.continuous))
            Text("Necesitamos acceso a la cámara")
                .font(.appHeadline)
            Text("Activa el permiso en Ajustes para escanear residuos.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.8))
            PrimaryButton("Abrir Ajustes", systemImage: "gear") {
                Haptics.tap()
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding(.horizontal, Spacing.xl)
        }
        .foregroundStyle(.white)
        .padding()
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.warning)
                .symbolEffect(.bounce)
            Text(message)
                .multilineTextAlignment(.center)
            PrimaryButton("Reintentar", systemImage: "arrow.clockwise") {
                Haptics.tap()
                coordinator.reset()
            }
            .padding(.horizontal, Spacing.xl)
        }
        .padding()
        .onAppear { Haptics.error() }
    }
}

#Preview {
    ScannerView()
}
