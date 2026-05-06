import SwiftUI

struct CoachView: View {
    /// Pregunta semilla — si está, se manda automáticamente al abrir el chat.
    /// Lo usa el Home para saltar al coach con contexto del progreso actual.
    var starterPrompt: String? = nil

    @State private var state = CoachState()
    @State private var didFireStarter = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cream.ignoresSafeArea()
                VStack(spacing: 0) {
                    if let note = state.availabilityNote {
                        availabilityBanner(note)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    conversation
                    inputBar
                }
            }
            .navigationTitle("Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !state.entries.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Haptics.tap()
                            state.reset()
                        } label: {
                            Label("Nueva conversación", systemImage: "arrow.counterclockwise")
                                .labelStyle(.iconOnly)
                                .foregroundStyle(.brand)
                        }
                    }
                }
            }
            .task {
                // Si llegamos con un prompt seed (desde el Home), lo mandamos
                // una sola vez al aparecer. Así el coach arranca con contexto
                // del estado de la cubeta — no en blanco.
                if let starter = starterPrompt, !didFireStarter, state.entries.isEmpty {
                    didFireStarter = true
                    await state.send(starter)
                }
            }
        }
    }

    private func availabilityBanner(_ note: String) -> some View {
        Label(note, systemImage: "info.circle.fill")
            .font(.appCaption)
            .foregroundStyle(.inkCharcoal.opacity(0.75))
            .padding(Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.info.opacity(0.12))
    }

    private var conversation: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Spacing.m) {
                    if state.entries.isEmpty {
                        greeter
                        suggestionChips
                    }
                    ForEach(state.entries) { entry in
                        bubble(entry)
                            .id(entry.id)
                            .transition(.asymmetric(
                                insertion: .move(edge: entry.role == .user ? .trailing : .leading)
                                    .combined(with: .opacity)
                                    .combined(with: .scale(scale: 0.92)),
                                removal: .opacity
                            ))
                    }
                    if state.isThinking {
                        thinkingIndicator
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    }
                    Color.clear.frame(height: 8).id("bottom")
                }
                .padding(Spacing.l)
                .animation(AppAnimation.spring, value: state.entries.count)
                .animation(AppAnimation.smooth, value: state.isThinking)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: state.entries.count) { _, _ in
                withAnimation(AppAnimation.smooth) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: state.isThinking) { _, _ in
                withAnimation(AppAnimation.smooth) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }

    private var greeter: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            ZStack {
                Circle()
                    .fill(Color.brand.opacity(0.15))
                    .frame(width: 64, height: 64)
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundStyle(.brand)
                    .symbolEffect(.variableColor.iterative.reversing, options: .repeat(.continuous))
            }
            Text("Hola, soy tu coach.")
                .font(.appTitle2.weight(.semibold))
                .foregroundStyle(.inkCharcoal)
            Text("Pregúntame cómo separar residuos, qué hacer con un objeto o cómo reducir tu basura. Corro en tu iPhone — tus preguntas no se mandan a internet.")
                .font(.appBody)
                .foregroundStyle(.inkCharcoal.opacity(0.65))
        }
        .padding(.vertical, Spacing.m)
    }

    private var suggestionChips: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Prueba con")
                .font(.appCaption.weight(.semibold))
                .foregroundStyle(.inkCharcoal.opacity(0.55))
                .textCase(.uppercase)
                .padding(.top, Spacing.s)
            FlowLayout(spacing: 8) {
                ForEach(state.suggestions, id: \.self) { suggestion in
                    Button {
                        Haptics.tap()
                        Task { await state.send(suggestion) }
                    } label: {
                        Text(suggestion)
                            .font(.appCallout)
                            .foregroundStyle(.brand)
                            .padding(.horizontal, Spacing.m)
                            .padding(.vertical, Spacing.s)
                            .background(.brand.opacity(0.12), in: .capsule)
                            .overlay {
                                Capsule().stroke(Color.brand.opacity(0.25), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func bubble(_ entry: CoachState.Entry) -> some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            if entry.role == .assistant {
                avatar(for: entry.role)
                bubbleContent(entry)
                Spacer(minLength: Spacing.l)
            } else {
                Spacer(minLength: Spacing.l)
                Text(entry.text)
                    .font(.appBody)
                    .foregroundStyle(.white)
                    .padding(Spacing.m)
                    .background(Color.brand, in: .rect(cornerRadius: 18))
                avatar(for: entry.role)
            }
        }
    }

    @ViewBuilder
    private func bubbleContent(_ entry: CoachState.Entry) -> some View {
        if let response = entry.response {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text(response.summary)
                    .font(.appBody.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                if !response.detail.isEmpty {
                    Text(response.detail)
                        .font(.appBody)
                        .foregroundStyle(.inkCharcoal.opacity(0.75))
                }
                if let tip = response.tip, !tip.isEmpty {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption)
                            .foregroundStyle(.warning)
                        Text(tip)
                            .font(.appCaption)
                            .foregroundStyle(.inkCharcoal.opacity(0.85))
                    }
                    .padding(Spacing.s)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.warning.opacity(0.12), in: .rect(cornerRadius: 10))
                }
            }
            .padding(Spacing.m)
            .background(.white, in: .rect(cornerRadius: 18))
            .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 6, y: 2)
        } else {
            Text(entry.text)
                .font(.appBody)
                .foregroundStyle(.inkCharcoal)
                .padding(Spacing.m)
                .background(.white, in: .rect(cornerRadius: 18))
                .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 6, y: 2)
        }
    }

    private func avatar(for role: CoachMessage.Role) -> some View {
        ZStack {
            Circle()
                .fill(role == .user ? Color.clay.opacity(0.20) : Color.brand.opacity(0.15))
                .frame(width: 32, height: 32)
            Image(systemName: role == .user ? "person.fill" : "sparkles")
                .font(.caption.weight(.semibold))
                .foregroundStyle(role == .user ? .clay : .brand)
        }
    }

    private var thinkingIndicator: some View {
        HStack(spacing: Spacing.s) {
            avatar(for: .assistant)
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(.brand.opacity(0.6))
                        .frame(width: 6, height: 6)
                        .scaleEffect(thinkScale(i))
                        .animation(
                            .easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(i) * 0.15),
                            value: state.isThinking
                        )
                }
            }
            .padding(Spacing.m)
            .background(.white, in: .rect(cornerRadius: 18))
            .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 6, y: 2)
            Spacer()
        }
    }

    private func thinkScale(_ i: Int) -> CGFloat {
        state.isThinking ? 1.3 : 0.7
    }

    private var inputBar: some View {
        HStack(spacing: Spacing.s) {
            TextField("Escribe tu pregunta…", text: $state.input, axis: .vertical)
                .focused($inputFocused)
                .lineLimit(1...4)
                .padding(.horizontal, Spacing.m)
                .padding(.vertical, Spacing.s)
                .background(.white, in: .capsule)
                .overlay {
                    Capsule().stroke(Color.inkCharcoal.opacity(0.10), lineWidth: 1)
                }
                .submitLabel(.send)
                .onSubmit { sendCurrent() }

            Button {
                sendCurrent()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.body.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(canSend ? Color.brand : Color.inkCharcoal.opacity(0.25), in: .circle)
                    .symbolEffect(.bounce, value: state.entries.count)
            }
            .disabled(!canSend)
            .accessibilityLabel("Enviar mensaje")
        }
        .padding(.horizontal, Spacing.l)
        .padding(.vertical, Spacing.s)
        .background(.bar)
    }

    private var canSend: Bool {
        !state.input.trimmingCharacters(in: .whitespaces).isEmpty && !state.isThinking
    }

    private func sendCurrent() {
        guard canSend else { return }
        Haptics.tap()
        Task { await state.send() }
    }
}

#Preview {
    CoachView()
}
