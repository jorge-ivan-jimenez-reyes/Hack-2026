import SwiftUI
import SwiftData

struct ResultView: View {
    let image: UIImage
    let classification: Classification
    let response: CoachResponse
    let onDone: () -> Void

    @Environment(\.modelContext) private var context

    @State private var revealed = false
    @State private var confettiTrigger = 0
    @State private var animatedConfidence: Double = 0

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    imagePreview
                    categoryHeader
                    explanationCard
                    if let tip = response.tip { tipCard(tip) }
                    if !classification.alternatives.isEmpty {
                        alternativesCard
                    }
                    actionsRow
                }
                .padding(Spacing.l)
            }

            // Confeti overlay — solo se activa al guardar
            ConfettiView(trigger: confettiTrigger)
                .ignoresSafeArea()
        }
        .background(Color.surface)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Haptics.success()
            withAnimation(AppAnimation.bouncy) {
                revealed = true
            }
            withAnimation(.easeOut(duration: 0.9).delay(0.2)) {
                animatedConfidence = classification.confidence
            }
        }
    }

    private var imagePreview: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 280)
            .frame(maxWidth: .infinity)
            .background(Color.surfaceMuted)
            .clipShape(RoundedRectangle(cornerRadius: Radius.l))
            .opacity(revealed ? 1 : 0)
            .scaleEffect(revealed ? 1 : 0.94)
            .accessibilityLabel("Foto del residuo capturado")
    }

    private var categoryHeader: some View {
        HStack(spacing: Spacing.m) {
            ZStack {
                Circle()
                    .fill(classification.category.color.opacity(0.2))
                Circle()
                    .trim(from: 0, to: animatedConfidence)
                    .stroke(classification.category.color, style: .init(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: classification.category.symbolName)
                    .font(.title)
                    .foregroundStyle(classification.category.color)
                    .symbolEffect(.bounce, value: revealed)
            }
            .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 2) {
                Text(classification.category.displayName)
                    .font(.appTitle2)
                Text("Bote \(classification.category.binColor) · \(classification.confidencePercentage)% confianza")
                    .font(.appCallout)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }
            Spacer()
        }
        .opacity(revealed ? 1 : 0)
        .offset(y: revealed ? 0 : 12)
        .accessibleCard(
            label: "\(classification.category.displayName), bote \(classification.category.binColor), \(classification.confidencePercentage) por ciento de confianza"
        )
    }

    private var explanationCard: some View {
        InfoCard(title: "Explicación", systemImage: "sparkles") {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text(response.summary)
                    .font(.appBody.weight(.semibold))
                Text(response.detail)
                    .font(.appBody)
                    .foregroundStyle(.secondary)
                HStack {
                    Spacer()
                    Label("Confianza del coach: \(response.confidence.rawValue)", systemImage: "checkmark.seal")
                        .font(.appCaption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .opacity(revealed ? 1 : 0)
        .offset(y: revealed ? 0 : 16)
        .animation(AppAnimation.entrance.delay(0.15), value: revealed)
    }

    private func tipCard(_ tip: String) -> some View {
        Label {
            Text(tip).font(.appCallout)
        } icon: {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.warning)
                .symbolEffect(.pulse, options: .repeat(.continuous))
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.warning.opacity(0.12), in: .rect(cornerRadius: Radius.l))
        .opacity(revealed ? 1 : 0)
        .offset(y: revealed ? 0 : 16)
        .animation(AppAnimation.entrance.delay(0.25), value: revealed)
    }

    private var alternativesCard: some View {
        InfoCard(title: "También podría ser", systemImage: "arrow.triangle.branch") {
            VStack(spacing: Spacing.s) {
                ForEach(classification.alternatives, id: \.category) { alt in
                    HStack {
                        CategoryBadge(category: alt.category, showsBin: false)
                        Spacer()
                        Text("\(Int(alt.confidence * 100))%")
                            .font(.appCallout)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .opacity(revealed ? 1 : 0)
        .offset(y: revealed ? 0 : 16)
        .animation(AppAnimation.entrance.delay(0.35), value: revealed)
    }

    private var actionsRow: some View {
        HStack(spacing: Spacing.m) {
            SecondaryButton(title: "Descartar") {
                Haptics.tap()
                onDone()
            }
            PrimaryButton("Guardar", systemImage: "tray.and.arrow.down.fill") {
                save()
                Haptics.success()
                confettiTrigger += 1
                Task {
                    try? await Task.sleep(for: .milliseconds(900))
                    onDone()
                }
            }
        }
        .opacity(revealed ? 1 : 0)
        .animation(AppAnimation.entrance.delay(0.45), value: revealed)
    }

    private func save() {
        let record = ScanRecord(
            category: classification.category,
            confidence: classification.confidence,
            summary: response.summary,
            detail: response.detail,
            tip: response.tip,
            imageData: image.jpegData(compressionQuality: 0.7)
        )
        context.insert(record)
        try? context.save()
    }
}
