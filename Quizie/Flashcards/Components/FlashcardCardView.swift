import SwiftUI

struct FlashcardCardView: View {
    let card: Flashcard
    @Binding var isFlipped: Bool
    let onRate: (Difficulty) -> Void

    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            cardFront
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))

            cardBack
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(rotation - 180), axis: (x: 0, y: 1, z: 0))
        }
        .onChange(of: isFlipped) { _, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                rotation = newValue ? 180 : 0
            }
        }
    }

    private var cardFront: some View {
        VStack(spacing: 24) {
            Text("Question")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Spacer()

            Text(card.question)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Text("Tap to reveal answer")
                .font(.footnote)
                .foregroundStyle(.tertiary)

            Spacer().frame(height: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(cardBackground)
        .contentShape(Rectangle())
        .onTapGesture {
            isFlipped = true
        }
    }

    private var cardBack: some View {
        VStack(spacing: 16) {
            Text("Answer")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            ScrollView {
                Text(card.answer)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxHeight: 200)

            Divider()
                .padding(.vertical, 8)

            Text("How did you do?")
                .font(.footnote)
                .foregroundStyle(.secondary)

            difficultyButtons
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(cardBackground)
    }

    private var difficultyButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                difficultyButton(.again)
                difficultyButton(.hard)
            }
            HStack(spacing: 12) {
                difficultyButton(.good)
                difficultyButton(.easy)
            }
        }
    }

    @ViewBuilder
    private func difficultyButton(_ difficulty: Difficulty) -> some View {
        Button {
            onRate(difficulty)
        } label: {
            HStack(spacing: 4) {
                Text(difficulty.emoji)
                Text(difficulty.label)
                    .fontWeight(.medium)
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(difficultyColor(difficulty).opacity(0.15))
            .foregroundStyle(difficultyColor(difficulty))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func difficultyColor(_ difficulty: Difficulty) -> Color {
        switch difficulty {
        case .again: return .red
        case .hard: return .orange
        case .good: return .green
        case .easy: return .blue
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.background)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isFlipped = false

        var body: some View {
            FlashcardCardView(
                card: Flashcard(
                    question: "What does 'Rule of Law' mean?",
                    answer: "That everyone is subject to the law, including the government.\n\nThis is a fundamental principle in the UK constitution.",
                    topic: "UK Values"
                ),
                isFlipped: $isFlipped,
                onRate: { _ in }
            )
            .frame(height: 450)
            .padding()
        }
    }

    return PreviewWrapper()
}
