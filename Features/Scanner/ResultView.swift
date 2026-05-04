import SwiftUI
import SwiftData

struct ResultView: View {
    let image: UIImage
    let classification: Classification
    let response: CoachResponse
    let onDone: () -> Void

    @Environment(\.modelContext) private var context

    var body: some View {
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
        .background(Color.surface)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var imagePreview: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 280)
            .frame(maxWidth: .infinity)
            .background(Color.surfaceMuted)
            .clipShape(RoundedRectangle(cornerRadius: Radius.l))
            .accessibilityLabel("Foto del residuo capturado")
    }

    private var categoryHeader: some View {
        HStack(spacing: Spacing.m) {
            ZStack {
                Circle()
                    .fill(classification.category.color.opacity(0.2))
                Image(systemName: classification.category.symbolName)
                    .font(.title)
                    .foregroundStyle(classification.category.color)
            }
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 2) {
                Text(classification.category.displayName)
                    .font(.appTitle2)
                Text("Bote \(classification.category.binColor) · \(classification.confidencePercentage)% confianza")
                    .font(.appCallout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .accessibleCard(label: "\(classification.category.displayName), bote \(classification.category.binColor), \(classification.confidencePercentage) por ciento de confianza")
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
    }

    private func tipCard(_ tip: String) -> some View {
        Label {
            Text(tip).font(.appCallout)
        } icon: {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.warning)
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.warning.opacity(0.12), in: .rect(cornerRadius: Radius.l))
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
    }

    private var actionsRow: some View {
        HStack(spacing: Spacing.m) {
            SecondaryButton(title: "Descartar", action: onDone)
            PrimaryButton("Guardar", systemImage: "tray.and.arrow.down.fill") {
                save()
                onDone()
            }
        }
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
