import SwiftUI

struct ScannerView: View {
    @State private var coordinator = ScannerCoordinator()

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
        case .error(let msg):
            errorView(msg)
        }
    }

    private var cameraStage: some View {
        ZStack(alignment: .bottom) {
            cameraLayer
                .ignoresSafeArea()
            captureControls
        }
        .background(Color.black)
    }

    @ViewBuilder
    private var cameraLayer: some View {
        switch coordinator.camera.status {
        case .running:
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
            captureButton
        }
        .padding(.bottom, Spacing.xxl)
    }

    @ViewBuilder
    private var statusPill: some View {
        switch coordinator.state {
        case .classifying:
            statusText("Clasificando…", systemImage: "sparkles")
        case .explaining:
            statusText("Generando explicación…", systemImage: "text.bubble.fill")
        case .capturing:
            statusText("Capturando…", systemImage: "camera.fill")
        default:
            EmptyView()
        }
    }

    private func statusText(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.appCallout)
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.s)
            .glassEffect(.regular, in: .rect(cornerRadius: Radius.pill))
    }

    private var captureButton: some View {
        Button {
            Task { await coordinator.captureAndClassify() }
        } label: {
            ZStack {
                Circle()
                    .stroke(.white, lineWidth: 4)
                    .frame(width: 84, height: 84)
                Circle()
                    .fill(.white)
                    .frame(width: 72, height: 72)
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

    private var permissionDeniedView: some View {
        VStack(spacing: Spacing.l) {
            Image(systemName: "camera.fill").font(.largeTitle)
            Text("Necesitamos acceso a la cámara")
                .font(.appHeadline)
            Text("Activa el permiso en Ajustes para escanear residuos.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.8))
            PrimaryButton("Abrir Ajustes", systemImage: "gear") {
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
            Text(message)
                .multilineTextAlignment(.center)
            PrimaryButton("Reintentar", systemImage: "arrow.clockwise") {
                coordinator.reset()
            }
            .padding(.horizontal, Spacing.xl)
        }
        .padding()
    }
}

#Preview {
    ScannerView()
}
