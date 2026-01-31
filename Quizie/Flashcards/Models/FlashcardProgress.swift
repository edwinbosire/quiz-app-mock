import Foundation

enum Difficulty: Int, Codable, CaseIterable {
    case again = 0
    case hard = 1
    case good = 2
    case easy = 3

    var label: String {
        switch self {
        case .again: return "Again"
        case .hard: return "Hard"
        case .good: return "Good"
        case .easy: return "Easy"
        }
    }

    var emoji: String {
        switch self {
        case .again: return ""
        case .hard: return ""
        case .good: return ""
        case .easy: return ""
        }
    }
}

struct FlashcardProgress: Codable, Hashable, Identifiable {
    var id: String { cardId }
    let cardId: String
    var reviewCount: Int
    var easeFactor: Double
    var interval: Int
    var nextReviewDate: Date
    var lastReviewedDate: Date?

    init(
        cardId: String,
        reviewCount: Int = 0,
        easeFactor: Double = 2.5,
        interval: Int = 0,
        nextReviewDate: Date? = nil,
        lastReviewedDate: Date? = nil
    ) {
        self.cardId = cardId
        self.reviewCount = reviewCount
        self.easeFactor = easeFactor
        self.interval = interval
        self.nextReviewDate = nextReviewDate ?? Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        self.lastReviewedDate = lastReviewedDate
    }

    var isDueToday: Bool {
        Calendar.current.isDateInToday(nextReviewDate) || nextReviewDate < Date()
    }

    var isMastered: Bool {
        interval >= 21 && easeFactor >= 2.5
    }

    mutating func updateAfterReview(difficulty: Difficulty) {
        reviewCount += 1
        lastReviewedDate = Date()

        let newEaseFactor = calculateNewEaseFactor(difficulty: difficulty)
        easeFactor = max(1.3, newEaseFactor)

        let newInterval = calculateNewInterval(difficulty: difficulty)
        interval = newInterval

        nextReviewDate = Calendar.current.date(byAdding: .day, value: newInterval, to: Date())!
    }

    private func calculateNewEaseFactor(difficulty: Difficulty) -> Double {
        let q = Double(difficulty.rawValue)
        return easeFactor + (0.1 - (3 - q) * (0.08 + (3 - q) * 0.02))
    }

    private func calculateNewInterval(difficulty: Difficulty) -> Int {
        switch difficulty {
        case .again:
            return 1
        case .hard:
            return max(1, Int(Double(interval) * 1.2))
        case .good:
            if reviewCount == 1 {
                return 1
            } else if reviewCount == 2 {
                return 6
            } else {
                return Int(Double(interval) * easeFactor)
            }
        case .easy:
            if reviewCount == 1 {
                return 4
            } else {
                return Int(Double(interval) * easeFactor * 1.3)
            }
        }
    }
}

extension FlashcardProgress {
    var intervalDescription: String {
        if interval == 0 {
            return "New"
        } else if interval == 1 {
            return "1 day"
        } else if interval < 7 {
            return "\(interval) days"
        } else if interval < 30 {
            let weeks = interval / 7
            return weeks == 1 ? "1 week" : "\(weeks) weeks"
        } else {
            let months = interval / 30
            return months == 1 ? "1 month" : "\(months) months"
        }
    }
}
