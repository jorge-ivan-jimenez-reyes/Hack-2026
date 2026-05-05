import SwiftUI

/// Banner-notificación que cae desde arriba. Glass tinted con el accent del
/// tipo de reminder. Tappable + swipeable para descartar.
struct ReminderBubble: View {
    let reminder: Reminder
    let onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.m) {
            // Icon en círculo tintado
            ZStack {
                Circle()
                    .fill(reminder.tint.opacity(0.20))
                Image(systemName: reminder.symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(reminder.tint)
                    .symbolEffect(.bounce, value: reminder.id)
            }
            .frame(width: 40, height: 40)

            // Title + body
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(.appCallout.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                    .lineLimit(1)
                Text(reminder.body)
                    .font(.appCaption)
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            // Close button
            Button {
                Haptics.tap()
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.inkCharcoal.opacity(0.45))
                    .frame(width: 28, height: 28)
                    .background(Color.inkCharcoal.opacity(0.06), in: .circle)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .background {
            RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                .fill(.ultraThickMaterial)
                .shadow(color: Color.inkCharcoal.opacity(0.18), radius: 24, y: 10)
        }
        .overlay {
            RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                .stroke(reminder.tint.opacity(0.22), lineWidth: 1)
        }
        .padding(.horizontal, Spacing.m)
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Solo permitir drag hacia arriba (descartar)
                    dragOffset = min(0, value.translation.height)
                }
                .onEnded { value in
                    if value.translation.height < -40 {
                        Haptics.tap()
                        onDismiss()
                    } else {
                        withAnimation(.snappy) { dragOffset = 0 }
                    }
                }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(reminder.title). \(reminder.body)")
    }
}

#Preview {
    ZStack {
        Color.cream.ignoresSafeArea()
        VStack {
            ReminderBubble(reminder: Reminder.bank[0]) { print("dismiss") }
            Spacer()
        }
        .padding(.top, 60)
    }
}
