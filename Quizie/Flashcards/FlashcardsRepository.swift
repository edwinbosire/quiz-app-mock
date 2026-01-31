import Foundation

protocol FlashcardsRepositoryProtocol {
    func loadAllCards() async throws -> [Flashcard]
    func saveCard(_ card: Flashcard) async throws
    func deleteCard(_ cardId: String) async throws
    func loadProgress(for cardId: String) -> FlashcardProgress?
    func loadAllProgress() -> [FlashcardProgress]
    func saveProgress(_ progress: FlashcardProgress) async throws
    func getCardsDueToday() async throws -> [Flashcard]
}

final class FlashcardsRepository: FlashcardsRepositoryProtocol {
    static let shared = FlashcardsRepository()

    private let storage: UserDefaults
    private static let FlashcardsKey = "FlashcardsKey"
    private static let ProgressKey = "FlashcardsProgressKey"
    private static let StreakKey = "FlashcardsStreakKey"
    private static let LastReviewDateKey = "FlashcardsLastReviewDateKey"

    init(storage: UserDefaults = UserDefaults(suiteName: "v0.0.1")!) {
        self.storage = storage
    }

    func loadAllCards() async throws -> [Flashcard] {
        guard let data = storage.data(forKey: Self.FlashcardsKey) else {
            return []
        }
        return try JSONDecoder().decode([Flashcard].self, from: data)
    }

    func saveCard(_ card: Flashcard) async throws {
        var cards = try await loadAllCards()

        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
        } else {
            cards.append(card)
        }

        let data = try JSONEncoder().encode(cards)
        storage.set(data, forKey: Self.FlashcardsKey)

        let progress = FlashcardProgress(cardId: card.id)
        try await saveProgress(progress)
    }

    func deleteCard(_ cardId: String) async throws {
        var cards = try await loadAllCards()
        cards.removeAll { $0.id == cardId }

        let data = try JSONEncoder().encode(cards)
        storage.set(data, forKey: Self.FlashcardsKey)

        var allProgress = loadAllProgress()
        allProgress.removeAll { $0.cardId == cardId }
        let progressData = try JSONEncoder().encode(allProgress)
        storage.set(progressData, forKey: Self.ProgressKey)
    }

    func loadProgress(for cardId: String) -> FlashcardProgress? {
        loadAllProgress().first { $0.cardId == cardId }
    }

    func loadAllProgress() -> [FlashcardProgress] {
        guard let data = storage.data(forKey: Self.ProgressKey) else {
            return []
        }
        return (try? JSONDecoder().decode([FlashcardProgress].self, from: data)) ?? []
    }

    func saveProgress(_ progress: FlashcardProgress) async throws {
        var allProgress = loadAllProgress()

        if let index = allProgress.firstIndex(where: { $0.cardId == progress.cardId }) {
            allProgress[index] = progress
        } else {
            allProgress.append(progress)
        }

        let data = try JSONEncoder().encode(allProgress)
        storage.set(data, forKey: Self.ProgressKey)
    }

    func getCardsDueToday() async throws -> [Flashcard] {
        let cards = try await loadAllCards()
        let allProgress = loadAllProgress()

        return cards.filter { card in
            if let progress = allProgress.first(where: { $0.cardId == card.id }) {
                return progress.isDueToday
            }
            return true
        }
    }

    func getMasteredCount() -> Int {
        loadAllProgress().filter { $0.isMastered }.count
    }

    func getCurrentStreak() -> Int {
        storage.integer(forKey: Self.StreakKey)
    }

    func updateStreakIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastReviewData = storage.object(forKey: Self.LastReviewDateKey) as? Date {
            let lastReviewDay = Calendar.current.startOfDay(for: lastReviewData)
            let daysDifference = Calendar.current.dateComponents([.day], from: lastReviewDay, to: today).day ?? 0

            if daysDifference == 0 {
                return
            } else if daysDifference == 1 {
                let currentStreak = getCurrentStreak()
                storage.set(currentStreak + 1, forKey: Self.StreakKey)
            } else {
                storage.set(1, forKey: Self.StreakKey)
            }
        } else {
            storage.set(1, forKey: Self.StreakKey)
        }

        storage.set(today, forKey: Self.LastReviewDateKey)
    }

    func scheduleNextReview(cardId: String, difficulty: Difficulty) async throws {
        guard var progress = loadProgress(for: cardId) else { return }
        progress.updateAfterReview(difficulty: difficulty)
        try await saveProgress(progress)
        updateStreakIfNeeded()
    }
}
