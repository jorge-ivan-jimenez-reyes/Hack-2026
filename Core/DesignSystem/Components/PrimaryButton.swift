import SwiftUI

struct PrimaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.s) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(.appHeadline)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.vertical, Spacing.s)
            .padding(.horizontal, Spacing.l)
        }
        .buttonStyle(.glassProminent)
        .tint(.brand)
        .controlSize(.large)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(.glass)
            .controlSize(.large)
            .frame(maxWidth: .infinity, minHeight: 44)
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        PrimaryButton("Capturar", systemImage: "camera.fill") {}
        SecondaryButton(title: "Cancelar") {}
    }
    .padding()
}
