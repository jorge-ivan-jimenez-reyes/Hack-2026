import SwiftUI

/// Card swipeable estilo Tinder/Hinge. El usuario arrastra a la derecha (composta)
/// o a la izquierda (no composta). Si suelta sin pasar el threshold, vuelve a
/// centro. Si lo cruza, dispara `onSwipe(true/false)`.
struct QuizCard: View {
    let question: QuizQuestion
    let onSwipe: (Bool) -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var visible: Bool = true

    private let swipeThreshold: CGFloat = 100

    var body: some View {
        cardBody
            .offset(dragOffset)
            .rotationEffect(.degrees(Double(dragOffset.width) / 20))
            .opacity(visible ? 1 : 0)
            .scaleEffect(visible ? 1 : 0.9)
            .gesture(dragGesture)
            .animation(.smooth(duration: 0.4, extraBounce: 0.05), value: dragOffset)
            .animation(.smooth(duration: 0.3), value: visible)
    }

    // MARK: - Card body

    private var cardBody: some View {
        VStack(spacing: Spacing.l) {
            // Hint de dirección al hacer drag
            HStack {
                if dragOffset.width < -20 {
                    decisionTag("NO va", color: .danger, side: .leading)
                }
                Spacer()
                if dragOffset.width > 20 {
                    decisionTag("Sí va", color: .brand, side: .trailing)
                }
            }
            .frame(height: 32)

            Spacer(minLength: 0)

            Image(systemName: question.symbol)
                .font(.system(size: 88, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.brand, .brand.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .symbolEffect(.bounce, value: question.id)

            Text(question.name)
                .font(.appLargeTitle)
                .foregroundStyle(.inkCharcoal)
                .multilineTextAlignment(.center)

            Text("¿Va a composta?")
                .font(.appBody)
                .foregroundStyle(.inkCharcoal.opacity(0.55))

            Spacer(minLength: 0)
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 460)
        .background {
            RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.10), radius: 24, y: 12)
        }
    }

    private enum Side { case leading, trailing }

    private func decisionTag(_ text: String, color: Color, side: Side) -> some View {
        Text(text)
            .font(.appHeadline.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, 6)
            .background(color.opacity(0.15), in: .capsule)
            .overlay {
                Capsule().stroke(color.opacity(0.45), lineWidth: 2)
            }
            .rotationEffect(.degrees(side == .leading ? -8 : 8))
    }

    // MARK: - Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                if abs(value.translation.width) > swipeThreshold {
                    let goesIn = value.translation.width > 0
                    Haptics.confirm()
                    swipeOut(direction: goesIn ? .trailing : .leading)
                    onSwipe(goesIn)
                } else {
                    dragOffset = .zero
                }
            }
    }

    private func swipeOut(direction: Side) {
        let exitX: CGFloat = direction == .trailing ? 600 : -600
        withAnimation(.smooth(duration: 0.3)) {
            dragOffset = CGSize(width: exitX, height: 0)
            visible = false
        }
    }
}
