import SwiftUI

struct BrowseFlashcardsView: View {
    @Environment(Router.self) private var router
    @State private var cards: [Flashcard] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = true

    private let repository: FlashcardsRepository

    init(repository: FlashcardsRepository = .shared) {
        self.repository = repository
    }

    private var filteredCards: [Flashcard] {
        if searchText.isEmpty {
            return cards
        }
        return cards.filter {
            $0.question.localizedCaseInsensitiveContains(searchText) ||
            $0.answer.localizedCaseInsensitiveContains(searchText) ||
            $0.topic.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedCards: [(String, [Flashcard])] {
        Dictionary(grouping: filteredCards, by: { $0.topic })
            .sorted { $0.key < $1.key }
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if cards.isEmpty {
                emptyView
            } else {
                listView
            }
        }
        .navigationTitle("All Flashcards")
        .searchable(text: $searchText, prompt: "Search cards")
        .task {
            await loadCards()
        }
    }

    private var listView: some View {
        List {
            ForEach(groupedCards, id: \.0) { topic, topicCards in
                Section(topic) {
                    ForEach(topicCards) { card in
                        cardRow(card)
                    }
                }
            }
        }
    }

    private func cardRow(_ card: Flashcard) -> some View {
        Button {
            router.navigate(to: .flashcardDetail(card), navigationType: .push)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.question)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                Text(card.answer)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Cards",
            systemImage: "rectangle.on.rectangle.angled",
            description: Text("Create flashcards to see them here.")
        )
    }

    private func loadCards() async {
        isLoading = true
        cards = (try? await repository.loadAllCards()) ?? []
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        BrowseFlashcardsView()
    }
    .environment(Router(isPresented: .constant(nil)))
}
