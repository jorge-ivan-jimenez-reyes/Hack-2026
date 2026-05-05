import SwiftUI

/// Tab de "Guía de reciclaje" — gamificada, interactiva.
/// Hero: reto del día (5 preguntas swipeables). Después: categorías para
/// aprender. Score persistente en @AppStorage.
struct RecyclingGuideView: View {
    @State private var questions: [QuizQuestion] = QuizQuestion.dailyChallenge()
    @State private var currentIndex = 0
    @State private var correctCount = 0
    @State private var lastFeedback: QuizFeedback?
    @State private var showResult = false

    @AppStorage("guide.totalCorrect") private var totalCorrect = 0
    @AppStorage("guide.totalAnswered") private var totalAnswered = 0

    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.l) {
                    header
                    progressCard
                    challengeSection
                    categoriesSection
                    Color.clear.frame(height: 60)
                }
                .padding(.vertical, Spacing.s)
            }
            .scrollIndicators(.hidden)

            // Feedback popup (correct/wrong + explanation)
            if let feedback = lastFeedback {
                feedbackOverlay(feedback)
            }
        }
        .sheet(isPresented: $showResult) {
            ResultSheet(correct: correctCount, total: questions.count) {
                resetChallenge()
                showResult = false
            }
            .presentationDetents([.height(420)])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Guía de reciclaje")
                    .font(.appTitle2)
                    .foregroundStyle(.inkCharcoal)
                Text("Aprende qué va a composta y qué no.")
                    .font(.appCallout)
                    .foregroundStyle(.inkCharcoal.opacity(0.65))
            }
            Spacer()
            Image(systemName: "book.closed.fill")
                .font(.system(size: 28))
                .foregroundStyle(.brand)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
    }

    private var progressCard: some View {
        let accuracy = totalAnswered > 0 ? Double(totalCorrect) / Double(totalAnswered) : 0
        return VStack(alignment: .leading, spacing: Spacing.m) {
            HStack {
                Text("Tu progreso")
                    .font(.appHeadline.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                Spacer()
                Text("\(totalCorrect)/\(totalAnswered)")
                    .font(.appCaption.weight(.semibold))
                    .foregroundStyle(.brand)
                    .contentTransition(.numericText())
            }
            ProgressView(value: accuracy)
                .tint(.brand)
            Text(progressMessage(accuracy: accuracy))
                .font(.appCaption)
                .foregroundStyle(.inkCharcoal.opacity(0.55))
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.white)
                .shadow(color: Color.inkCharcoal.opacity(0.05), radius: 8, y: 3)
        }
        .padding(.horizontal, Spacing.l)
    }

    private func progressMessage(accuracy: Double) -> String {
        if totalAnswered == 0 { return "Empieza el reto del día." }
        if accuracy > 0.85 { return "Estás dominando. Pro." }
        if accuracy > 0.6 { return "Vas bien. Pulamos los detalles." }
        return "Hay material para aprender. Vamos."
    }

    private var challengeSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack {
                Image(systemName: "gamecontroller.fill")
                    .foregroundStyle(.clay)
                Text("Reto del día")
                    .font(.appHeadline.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
                Spacer()
                Text("\(currentIndex)/\(questions.count)")
                    .font(.appCaption.weight(.semibold))
                    .foregroundStyle(.inkCharcoal.opacity(0.55))
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, Spacing.l)

            ZStack {
                if currentIndex < questions.count {
                    QuizCard(question: questions[currentIndex]) { goesIn in
                        handleSwipe(goesIn: goesIn)
                    }
                    .id(questions[currentIndex].id)
                    .padding(.horizontal, Spacing.l)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.92).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
            .animation(.smooth(duration: 0.4), value: currentIndex)

            // Tap fallback for accessibility
            HStack(spacing: Spacing.m) {
                actionButton(label: "No va", icon: "xmark", color: .danger) {
                    handleSwipe(goesIn: false)
                }
                actionButton(label: "Sí va", icon: "checkmark", color: .brand) {
                    handleSwipe(goesIn: true)
                }
            }
            .padding(.horizontal, Spacing.l)
        }
    }

    private func actionButton(label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.body.weight(.bold))
                Text(label)
                    .font(.appBody.weight(.semibold))
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background {
                Capsule()
                    .fill(color.opacity(0.15))
            }
            .overlay {
                Capsule().stroke(color.opacity(0.30), lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
        .disabled(currentIndex >= questions.count)
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack {
                Image(systemName: "list.bullet.rectangle.fill")
                    .foregroundStyle(.brand)
                Text("Aprende por categoría")
                    .font(.appHeadline.weight(.semibold))
                    .foregroundStyle(.inkCharcoal)
            }
            .padding(.horizontal, Spacing.l)

            VStack(spacing: Spacing.s) {
                CategoryCard(title: "Orgánico", symbol: "leaf.fill", tint: .brand, itemCount: 18) {}
                CategoryCard(title: "PET", symbol: "drop.fill", tint: .info, itemCount: 12) {}
                CategoryCard(title: "Vidrio", symbol: "wineglass.fill", tint: .clay, itemCount: 8) {}
                CategoryCard(title: "Papel y cartón", symbol: "newspaper.fill", tint: .moss, itemCount: 14) {}
                CategoryCard(title: "Metal", symbol: "circle.hexagongrid.fill", tint: .warning, itemCount: 9) {}
                CategoryCard(title: "Electrónico", symbol: "bolt.fill", tint: .danger, itemCount: 11) {}
            }
            .padding(.horizontal, Spacing.l)
        }
    }

    // MARK: - Feedback overlay

    @ViewBuilder
    private func feedbackOverlay(_ feedback: QuizFeedback) -> some View {
        VStack {
            Spacer()
            VStack(spacing: Spacing.s) {
                HStack(spacing: Spacing.s) {
                    Image(systemName: feedback.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(feedback.correct ? .brand : .danger)
                        .symbolEffect(.bounce)
                    Text(feedback.correct ? "¡Correcto!" : "Casi, pero no")
                        .font(.appHeadline.weight(.bold))
                        .foregroundStyle(.inkCharcoal)
                }
                Text(feedback.explanation)
                    .font(.appCallout)
                    .foregroundStyle(.inkCharcoal.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(Spacing.l)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(.white)
                    .shadow(color: Color.inkCharcoal.opacity(0.18), radius: 24, y: 8)
            }
            .padding(.horizontal, Spacing.l)
            .padding(.bottom, Spacing.xl)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Logic

    private func handleSwipe(goesIn: Bool) {
        guard currentIndex < questions.count else { return }
        let q = questions[currentIndex]
        let correct = (goesIn == q.goesInCompost)

        if correct {
            correctCount += 1
            totalCorrect += 1
            Haptics.success()
        } else {
            Haptics.warning()
        }
        totalAnswered += 1

        withAnimation {
            lastFeedback = QuizFeedback(correct: correct, explanation: q.explanation)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation {
                lastFeedback = nil
            }
            advanceToNext()
        }
    }

    private func advanceToNext() {
        currentIndex += 1
        if currentIndex >= questions.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showResult = true
            }
        }
    }

    private func resetChallenge() {
        questions = QuizQuestion.dailyChallenge()
        currentIndex = 0
        correctCount = 0
    }
}

// MARK: - Helpers

private struct QuizFeedback: Equatable {
    let correct: Bool
    let explanation: String
}

private struct ResultSheet: View {
    let correct: Int
    let total: Int
    let onRetry: () -> Void

    private var percent: Int {
        guard total > 0 else { return 0 }
        return Int((Double(correct) / Double(total)) * 100)
    }

    var body: some View {
        VStack(spacing: Spacing.l) {
            Image(systemName: percent >= 80 ? "trophy.fill" : "sparkles")
                .font(.system(size: 56))
                .foregroundStyle(percent >= 80 ? .clay : .brand)
                .symbolEffect(.bounce, options: .repeat(2))
                .padding(.top, Spacing.l)

            Text("\(correct) de \(total)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(.inkCharcoal)
                .contentTransition(.numericText())

            Text(percent >= 80 ? "Eres pro 🏆" : "Vas progresando 💪")
                .font(.appHeadline)
                .foregroundStyle(.inkCharcoal.opacity(0.65))

            Button {
                Haptics.tap()
                onRetry()
            } label: {
                HStack(spacing: Spacing.s) {
                    Text("Otro reto")
                        .font(.appHeadline.weight(.semibold))
                    Image(systemName: "arrow.clockwise")
                }
                .foregroundStyle(.cream)
                .frame(maxWidth: .infinity, minHeight: 52)
                .padding(.horizontal, Spacing.l)
                .glassEffect(
                    .regular.tint(Color.brand.opacity(0.95)).interactive(),
                    in: .capsule
                )
            }
            .padding(.horizontal, Spacing.l)
            .padding(.bottom, Spacing.l)
        }
        .padding(.horizontal, Spacing.l)
        .background(Color.cream)
    }
}

#Preview {
    RecyclingGuideView()
}
