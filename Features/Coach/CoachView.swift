import SwiftUI

struct CoachView: View {
    @State private var state = CoachState()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let note = state.availabilityNote {
                    availabilityBanner(note)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                conversation
                inputBar
            }
            .navigationTitle("Coach")
        }
    }

    private func availabilityBanner(_ note: String) -> some View {
        Label(note, systemImage: "info.circle.fill")
            .font(.appCaption)
            .padding(Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.info.opacity(0.12))
    }

    private var conversation: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Spacing.m) {
                    if state.messages.isEmpty { greeter }
                    ForEach(state.messages) { msg in
                        bubble(msg)
                            .id(msg.id)
                            .transition(.asymmetric(
                                insertion: .move(edge: msg.role == .user ? .trailing : .leading)
                                    .combined(with: .opacity)
                                    .combined(with: .scale(scale: 0.92)),
                                removal: .opacity
                            ))
                    }
                    if state.isThinking {
                        thinkingIndicator
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    }
                }
                .padding(Spacing.l)
                .animation(AppAnimation.spring, value: state.messages.count)
                .animation(AppAnimation.smooth, value: state.isThinking)
            }
            .background(Color.surface)
            .onChange(of: state.messages.count) { _, _ in
                if let last = state.messages.last {
                    withAnimation(AppAnimation.smooth) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var greeter: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(.brand)
                .symbolEffect(.variableColor.iterative, options: .repeat(.continuous))
            Text("Pregúntame")
                .font(.appTitle)
            Text("Cómo separar residuos, qué hacer con un objeto específico, o tips para reducir tu basura.")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, Spacing.l)
    }

    private func bubble(_ msg: CoachMessage) -> some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            if msg.role == .assistant {
                avatar(for: msg.role)
            } else {
                Spacer(minLength: Spacing.xl)
            }
            Text(msg.text)
                .font(.appBody)
                .padding(Spacing.m)
                .background(
                    msg.role == .user
                    ? AnyShapeStyle(Color.brand.opacity(0.15))
                    : AnyShapeStyle(.regularMaterial),
                    in: .rect(cornerRadius: Radius.m)
                )
            if msg.role == .user {
                avatar(for: msg.role)
            } else {
                Spacer(minLength: Spacing.xl)
            }
        }
    }

    private func avatar(for role: CoachMessage.Role) -> some View {
        Image(systemName: role == .user ? "person.fill" : "sparkles")
            .frame(width: 32, height: 32)
            .background(.thinMaterial, in: .circle)
    }

    private var thinkingIndicator: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: "ellipsis")
                .symbolEffect(.variableColor.iterative, options: .repeat(.continuous))
                .foregroundStyle(.brand)
            Text("Pensando…")
                .font(.appCaption)
                .foregroundStyle(.secondary)
        }
    }

    private var inputBar: some View {
        HStack(spacing: Spacing.s) {
            TextField("Escribe tu pregunta…", text: $state.input, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
            Button {
                Haptics.tap()
                Task { await state.send() }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundStyle(.brand)
                    .symbolEffect(.bounce, value: state.messages.count)
            }
            .disabled(state.input.trimmingCharacters(in: .whitespaces).isEmpty || state.isThinking)
            .minTouchTarget()
            .accessibilityLabel("Enviar mensaje")
        }
        .padding(Spacing.m)
        .background(.bar)
    }
}

#Preview {
    CoachView()
}
