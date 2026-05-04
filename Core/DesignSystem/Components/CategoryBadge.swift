import SwiftUI

struct CategoryBadge: View {
    let category: WasteCategory
    var showsBin: Bool = true

    var body: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: category.symbolName)
                .font(.callout)
            VStack(alignment: .leading, spacing: 0) {
                Text(category.displayName)
                    .font(.appCallout.weight(.semibold))
                if showsBin {
                    Text("Bote \(category.binColor)")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .background(category.color.opacity(0.18), in: .rect(cornerRadius: Radius.pill))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.pill)
                .stroke(category.color.opacity(0.4), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(category.displayName), bote \(category.binColor)")
    }
}

#Preview {
    VStack(spacing: Spacing.s) {
        ForEach(WasteCategory.allCases) { cat in
            CategoryBadge(category: cat)
        }
    }
    .padding()
}
