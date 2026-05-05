import SwiftUI

/// Card de categoría (Orgánico, PET, Vidrio, etc) que abre una hoja con info
/// detallada. Visualmente: ícono coloreado + título + count de items.
struct CategoryCard: View {
    let title: String
    let symbol: String
    let tint: Color
    let itemCount: Int
    let onTap: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            onTap()
        } label: {
            HStack(spacing: Spacing.m) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.15))
                    Image(systemName: symbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(tint)
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.appHeadline.weight(.semibold))
                        .foregroundStyle(.inkCharcoal)
                    Text("\(itemCount) objetos comunes")
                        .font(.appCaption)
                        .foregroundStyle(.inkCharcoal.opacity(0.55))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.inkCharcoal.opacity(0.30))
            }
            .padding(Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(.white)
                    .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 8, y: 3)
            }
        }
        .buttonStyle(.plain)
    }
}
