import SwiftUI

struct FlashcardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router

    let card: Flashcard
    @State private var showDeleteConfirmation: Bool = false
    @State private var isDeleting: Bool = false

    private let repository: FlashcardsRepository

    init(card: Flashcard, repository: FlashcardsRepository = .shared) {
        self.card = card
        self.repository = repository
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                section(title: "Question") {
                    Text(card.question)
                        .font(.body)
                }

                section(title: "Answer") {
                    Text(card.answer)
                        .font(.body)
                }

                section(title: "Topic") {
                    Text(card.topic)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                if let progress = repository.loadProgress(for: card.id) {
                    section(title: "Progress") {
                        VStack(alignment: .leading, spacing: 8) {
                            progressRow("Reviews", value: "\(progress.reviewCount)")
                            progressRow("Interval", value: progress.intervalDescription)
                            progressRow("Next Review", value: formatDate(progress.nextReviewDate))
                        }
                    }
                }

                Spacer(minLength: 40)

                deleteButton
            }
            .padding()
        }
        .navigationTitle("Flashcard")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete Flashcard",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteCard()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    @ViewBuilder
    private func section(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func progressRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Delete Flashcard")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.1))
            .foregroundStyle(.red)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isDeleting)
    }

    private func deleteCard() {
        isDeleting = true
        Task {
            try? await repository.deleteCard(card.id)
            await MainActor.run {
                router.navigateBack()
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

#Preview {
    NavigationStack {
        FlashcardDetailView(
            card: Flashcard(
                question: "What does 'Rule of Law' mean?",
                answer: "That everyone is subject to the law, including the government.",
                topic: "UK Values"
            )
        )
    }
    .environment(Router(isPresented: .constant(nil)))
}
