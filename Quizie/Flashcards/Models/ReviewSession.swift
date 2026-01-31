import Foundation

struct ReviewSession: Identifiable {
    let id: String
    var cards: [Flashcard]
    var currentIndex: Int
    var completedCount: Int
    var startTime: Date
    var ratings: [String: Difficulty]

    init(
        id: String = UUID().uuidString,
        cards: [Flashcard],
        currentIndex: Int = 0,
        completedCount: Int = 0,
        startTime: Date = Date(),
        ratings: [String: Difficulty] = [:]
    ) {
        self.id = id
        self.cards = Self.interleaveByTopic(cards)
        self.currentIndex = currentIndex
        self.completedCount = completedCount
        self.startTime = startTime
        self.ratings = ratings
    }

    var currentCard: Flashcard? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }

    var isComplete: Bool {
        currentIndex >= cards.count
    }

    var progress: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(completedCount) / Double(cards.count)
    }

    var estimatedMinutes: Int {
        max(1, cards.count / 2)
    }

    var elapsedTime: TimeInterval {
        Date().timeIntervalSince(startTime)
    }

    mutating func rateCurrentCard(_ difficulty: Difficulty) {
        guard let card = currentCard else { return }
        ratings[card.id] = difficulty
        completedCount += 1
        currentIndex += 1
    }

    private static func interleaveByTopic(_ cards: [Flashcard]) -> [Flashcard] {
        guard cards.count > 2 else { return cards }

        var result: [Flashcard] = []
        var remaining = cards.shuffled()

        while !remaining.isEmpty {
            let lastTopic = result.suffix(2).map { $0.topic }

            if let index = remaining.firstIndex(where: { card in
                !lastTopic.allSatisfy { $0 == card.topic }
            }) {
                result.append(remaining.remove(at: index))
            } else {
                result.append(remaining.removeFirst())
            }
        }

        return result
    }
}

extension ReviewSession {
    struct Summary {
        let totalCards: Int
        let againCount: Int
        let hardCount: Int
        let goodCount: Int
        let easyCount: Int
        let duration: TimeInterval

        var formattedDuration: String {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            if minutes > 0 {
                return "\(minutes)m \(seconds)s"
            }
            return "\(seconds)s"
        }
    }

    var summary: Summary {
        Summary(
            totalCards: cards.count,
            againCount: ratings.values.filter { $0 == .again }.count,
            hardCount: ratings.values.filter { $0 == .hard }.count,
            goodCount: ratings.values.filter { $0 == .good }.count,
            easyCount: ratings.values.filter { $0 == .easy }.count,
            duration: elapsedTime
        )
    }
}
