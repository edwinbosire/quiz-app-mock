import Foundation

struct Flashcard: Codable, Hashable, Identifiable {
    let id: String
    let question: String
    let answer: String
    let topic: String
    let hint: String?
    let sourceQuestionId: String?
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        question: String,
        answer: String,
        topic: String,
        hint: String? = nil,
        sourceQuestionId: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.question = question
        self.answer = answer
        self.topic = topic
        self.hint = hint
        self.sourceQuestionId = sourceQuestionId
        self.createdAt = createdAt
    }
}

extension Flashcard {
    static func fromQuestion(_ question: Question, explanation: String?, topic: String) -> Flashcard {
        let correctAnswers = question.choices
            .filter { $0.isAnswer }
            .map { $0.title }
            .joined(separator: ", ")

        var answerText = correctAnswers
        if let explanation = explanation, !explanation.isEmpty {
            answerText += "\n\n\(explanation)"
        }

        return Flashcard(
            question: question.title,
            answer: answerText,
            topic: topic,
            sourceQuestionId: question.id
        )
    }
}
