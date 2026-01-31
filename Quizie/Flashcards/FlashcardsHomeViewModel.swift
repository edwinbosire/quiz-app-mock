import Foundation

@MainActor @Observable
final class FlashcardsHomeViewModel: Identifiable {
    let id = UUID()

    private let repository: FlashcardsRepository

    private(set) var dueCardsCount: Int = 0
    private(set) var totalCardsCount: Int = 0
    private(set) var masteredCount: Int = 0
    private(set) var streak: Int = 0
    private(set) var viewState: ViewState = .loading

    enum ViewState {
        case loading
        case content
        case empty
        case error
    }

    init(repository: FlashcardsRepository = .shared) {
        self.repository = repository
    }

    static func viewDidLoad() async -> FlashcardsHomeViewModel {
        let vm = FlashcardsHomeViewModel()
        await vm.loadStats()
        return vm
    }

    func loadStats() async {
        viewState = .loading
        do {
            let allCards = try await repository.loadAllCards()
            let dueCards = try await repository.getCardsDueToday()

            totalCardsCount = allCards.count
            dueCardsCount = dueCards.count
            masteredCount = repository.getMasteredCount()
            streak = repository.getCurrentStreak()

            viewState = allCards.isEmpty ? .empty : .content
        } catch {
            viewState = .error
        }
    }

    var hasDueCards: Bool {
        dueCardsCount > 0
    }

    var estimatedReviewMinutes: Int {
        max(1, dueCardsCount / 2)
    }
}
