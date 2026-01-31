import SwiftUI

struct CreateFlashcardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var question: String = ""
    @State private var answer: String = ""
    @State private var topic: String = ""
    @State private var isSaving: Bool = false
    @State private var showError: Bool = false

    private let repository: FlashcardsRepository

    init(repository: FlashcardsRepository = .shared) {
        self.repository = repository
    }

    private var isValid: Bool {
        !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
				Section(header: Text("Question and Answer")) {
					VStack(alignment: .leading) {
						Text("Question")
							.font(.title2)
						TextField("Enter question", text: $question, axis: .vertical)
							.lineLimit(3...6)
							.textFieldStyle(.flashcard)

						Text("What do you want to remember?")
							.font(.subheadline)
					}

					VStack(alignment: .leading) {
						Text("Answer")
							.font(.title2)
						TextField("Enter answer", text: $answer, axis: .vertical)
							.lineLimit(3...6)
							.textFieldStyle(.flashcard)
						Text("The answer you want to recall.")
							.font(.subheadline)

					}

                }

                Section {

						TextField("e.g., British History", text: $topic)
//							.textFieldStyle(.flashcard)
				} header: {
					Text("Topic (Optional)")
						.font(.title2)
				}

				Section {
					Button(action: {
						saveCard()
					}, label: {
						Text("Save Flashcard")
							.fontWeight(.bold)
							.foregroundStyle(Color.white)
							.padding()
							.frame(maxWidth: .infinity)
					})
					.background((!isValid || isSaving) ? Color.gray : PastelTheme.background, in: Capsule())
					.disabled(!isValid || isSaving)

				}
				.listRowBackground(Color.clear)

            }
            .navigationTitle("New Flashcard")
            .navigationBarTitleDisplayMode(.inline)
//			.background(PastelTheme.background)
//			.scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
					Button(role: .cancel) {
						dismiss()
					}
                }

                ToolbarItem(placement: .confirmationAction) {
					Button(role: .confirm) {
						saveCard()
					}
                    .disabled(!isValid || isSaving)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Failed to save flashcard. Please try again.")
            }
        }
    }

    private func saveCard() {
        isSaving = true

        let card = Flashcard(
            question: question.trimmingCharacters(in: .whitespacesAndNewlines),
            answer: answer.trimmingCharacters(in: .whitespacesAndNewlines),
            topic: topic.isEmpty ? "General" : topic.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        Task {
            do {
                try await repository.saveCard(card)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    showError = true
                }
            }
        }
    }
}



#Preview {
    CreateFlashcardView()
}
