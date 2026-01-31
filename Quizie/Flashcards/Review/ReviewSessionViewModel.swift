import Foundation

@MainActor @Observable
final class ReviewSessionViewModel: Identifiable {
    let id = UUID()

    private let repository: FlashcardsRepository
    private(set) var session: ReviewSession?
    private(set) var viewState: ViewState = .loading

    var isFlipped: Bool = false

    enum ViewState {
        case loading
        case ready
        case reviewing
        case complete
        case empty
        case error
    }

    init(repository: FlashcardsRepository = .shared) {
        self.repository = repository
    }

    static func viewDidLoad() async -> ReviewSessionViewModel {
        let vm = ReviewSessionViewModel()
        await vm.loadDueCards()
        return vm
    }

    func loadDueCards() async {
        viewState = .loading
        do {
            let dueCards = try await repository.getCardsDueToday()
            if dueCards.isEmpty {
                viewState = .empty
            } else {
                session = ReviewSession(cards: dueCards)
                viewState = .ready
            }
        } catch {
            viewState = .error
        }
    }

    func startSession() {
        viewState = .reviewing
        isFlipped = false
    }

    func rateCurrentCard(_ difficulty: Difficulty) {
        guard var session = session else { return }

        if let currentCard = session.currentCard {
            Task {
                try? await repository.scheduleNextReview(cardId: currentCard.id, difficulty: difficulty)
            }
        }

        session.rateCurrentCard(difficulty)
        self.session = session
        isFlipped = false

        if session.isComplete {
            viewState = .complete
        }
    }

    var currentCard: Flashcard? {
        session?.currentCard
    }

    var progress: Double {
        session?.progress ?? 0
    }

    var cardCount: Int {
        session?.cards.count ?? 0
    }

    var estimatedMinutes: Int {
        session?.estimatedMinutes ?? 0
    }

    var completedCount: Int {
        session?.completedCount ?? 0
    }

    var summary: ReviewSession.Summary? {
        session?.summary
    }
}
