import SwiftUI

struct InfoCard<Content: View>: View {
    let title: String?
    let systemImage: String?
    @ViewBuilder let content: () -> Content

    init(
        title: String? = nil,
        systemImage: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            if title != nil || systemImage != nil {
                Label {
                    if let title {
                        Text(title).font(.appHeadline)
                    }
                } icon: {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .foregroundStyle(.brand)
                    }
                }
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.l)
        .background(Color.surfaceElevated, in: .rect(cornerRadius: Radius.l))
    }
}

#Preview {
    InfoCard(title: "Explicación", systemImage: "sparkles") {
        Text("Este envase de PET puede reciclarse hasta 7 veces antes de degradarse.")
            .foregroundStyle(.secondary)
    }
    .padding()
}
