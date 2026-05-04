import SwiftUI

struct CoachView: View {
    @State private var state = CoachState()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let note = state.availabilityNote {
                    availabilityBanner(note)
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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.m) {
                if state.messages.isEmpty { greeter }
                ForEach(state.messages) { msg in
                    bubble(msg)
                }
                if state.isThinking { thinkingIndicator }
            }
            .padding(Spacing.l)
        }
        .background(Color.surface)
    }

    private var greeter: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(.brand)
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
            ProgressView().controlSize(.small)
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
                Task { await state.send() }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundStyle(.brand)
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
