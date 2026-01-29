//
//  TestDataFactory.swift
//  QuizUp-MockTests
//
//  Created by Claude Code on 29/01/2026.
//

import Foundation
@testable import Life_In_The_UK_Prep

/// Factory for creating test data for exam module tests
@MainActor
struct TestDataFactory {

    // MARK: - Single Answer Questions

    /// Creates a question with exactly one correct answer
    /// - Parameters:
    ///   - id: Question identifier
    ///   - correctIndex: Index of the correct choice (0-3)
    /// - Returns: A Question with 4 choices, one correct
    static func makeSingleAnswerQuestion(id: String = "q1", correctIndex: Int = 0) -> Question {
        let choices = [
            Choice(title: "Answer A", isAnswer: correctIndex == 0),
            Choice(title: "Answer B", isAnswer: correctIndex == 1),
            Choice(title: "Answer C", isAnswer: correctIndex == 2),
            Choice(title: "Answer D", isAnswer: correctIndex == 3)
        ]
        return Question(
            id: id,
            sectionId: "section1",
            title: "Single answer question \(id)",
            hint: "Hint for question \(id)",
            choices: choices
        )
    }

    // MARK: - Multi-Answer Questions

    /// Creates a question with multiple correct answers
    /// - Parameters:
    ///   - id: Question identifier
    ///   - correctIndices: Indices of correct choices (e.g., [0, 1] for A and B)
    /// - Returns: A Question with 4 choices, multiple correct
    static func makeMultiAnswerQuestion(id: String = "q2", correctIndices: [Int] = [0, 1]) -> Question {
        let choices = [
            Choice(title: "Answer A", isAnswer: correctIndices.contains(0)),
            Choice(title: "Answer B", isAnswer: correctIndices.contains(1)),
            Choice(title: "Answer C", isAnswer: correctIndices.contains(2)),
            Choice(title: "Answer D", isAnswer: correctIndices.contains(3))
        ]
        return Question(
            id: id,
            sectionId: "section1",
            title: "Multi answer question \(id)",
            hint: "Hint for question \(id)",
            choices: choices
        )
    }

    // MARK: - Exams

    /// Creates an exam with a mix of single and multi-answer questions
    /// - Parameters:
    ///   - id: Exam identifier
    ///   - questionCount: Total number of questions
    ///   - multiAnswerCount: Number of multi-answer questions (rest will be single-answer)
    /// - Returns: An Exam with the specified composition
    static func makeExam(id: Int = 1, questionCount: Int = 4, multiAnswerCount: Int = 0) -> Exam {
        var questions: [Question] = []
        for i in 0..<questionCount {
            if i < multiAnswerCount {
                questions.append(makeMultiAnswerQuestion(id: "q\(i)", correctIndices: [0, 1]))
            } else {
                questions.append(makeSingleAnswerQuestion(id: "q\(i)", correctIndex: 0))
            }
        }
        return Exam(id: id, questions: questions)
    }

    // MARK: - AttemptedQuestion Helpers

    /// Creates an AttemptedQuestion with all correct answers selected
    static func makeCorrectlyAnsweredQuestion(from question: Question) -> AttemptedQuestion {
        var attempted = AttemptedQuestion(from: question)
        let correctChoices = question.choices.filter { $0.isAnswer }
        for choice in correctChoices {
            attempted.updateSelected(choice, state: .correct)
        }
        return attempted
    }

    /// Creates an AttemptedQuestion with a wrong answer selected
    static func makeIncorrectlyAnsweredQuestion(from question: Question) -> AttemptedQuestion {
        var attempted = AttemptedQuestion(from: question)
        let wrongChoice = question.choices.first { !$0.isAnswer }!
        attempted.updateSelected(wrongChoice, state: .wrong)
        return attempted
    }

    /// Creates an AttemptedQuestion with partial correct answers (for multi-answer questions)
    static func makePartiallyAnsweredQuestion(from question: Question) -> AttemptedQuestion {
        var attempted = AttemptedQuestion(from: question)
        if let firstCorrect = question.choices.first(where: { $0.isAnswer }) {
            attempted.updateSelected(firstCorrect, state: .correct)
        }
        return attempted
    }

    /// Creates an AttemptedQuestion with one correct and one wrong answer (multi-answer scenario)
    static func makeOneCorrectOneWrongQuestion(from question: Question) -> AttemptedQuestion {
        var attempted = AttemptedQuestion(from: question)
        // Add one correct answer
        if let correctChoice = question.choices.first(where: { $0.isAnswer }) {
            attempted.updateSelected(correctChoice, state: .correct)
        }
        // Add one wrong answer
        if let wrongChoice = question.choices.first(where: { !$0.isAnswer }) {
            attempted.updateSelected(wrongChoice, state: .wrong)
        }
        return attempted
    }

    // MARK: - AttemptedExam Helpers

    /// Creates an AttemptedExam with specified number of correct/incorrect questions
    /// - Parameters:
    ///   - examId: Exam identifier
    ///   - correctCount: Number of correctly answered questions
    ///   - incorrectCount: Number of incorrectly answered questions
    ///   - unansweredCount: Number of unanswered questions
    /// - Returns: An AttemptedExam with the specified composition
    static func makeAttemptedExam(
        examId: Int = 1,
        correctCount: Int = 2,
        incorrectCount: Int = 1,
        unansweredCount: Int = 1
    ) -> AttemptedExam {
        var questions: [AttemptedQuestion] = []

        // Add correct questions
        for i in 0..<correctCount {
            let question = makeSingleAnswerQuestion(id: "correct\(i)", correctIndex: 0)
            questions.append(makeCorrectlyAnsweredQuestion(from: question))
        }

        // Add incorrect questions
        for i in 0..<incorrectCount {
            let question = makeSingleAnswerQuestion(id: "incorrect\(i)", correctIndex: 0)
            questions.append(makeIncorrectlyAnsweredQuestion(from: question))
        }

        // Add unanswered questions
        for i in 0..<unansweredCount {
            let question = makeSingleAnswerQuestion(id: "unanswered\(i)", correctIndex: 0)
            questions.append(AttemptedQuestion(from: question))
        }

        return AttemptedExam(
            examId: examId,
            questions: questions,
            status: .finished,
            dateAttempted: Date(),
            duration: 300
        )
    }

    /// Creates an AttemptedExam with multi-answer questions
    static func makeAttemptedExamWithMultiAnswer(
        examId: Int = 1,
        multiAnswerAllCorrect: Int = 1,
        multiAnswerOneWrong: Int = 1,
        singleAnswerCorrect: Int = 1,
        singleAnswerWrong: Int = 1
    ) -> AttemptedExam {
        var questions: [AttemptedQuestion] = []

        // Multi-answer: all correct
        for i in 0..<multiAnswerAllCorrect {
            let question = makeMultiAnswerQuestion(id: "multiCorrect\(i)", correctIndices: [0, 1])
            questions.append(makeCorrectlyAnsweredQuestion(from: question))
        }

        // Multi-answer: one wrong (should mark entire question wrong)
        for i in 0..<multiAnswerOneWrong {
            let question = makeMultiAnswerQuestion(id: "multiWrong\(i)", correctIndices: [0, 1])
            questions.append(makeOneCorrectOneWrongQuestion(from: question))
        }

        // Single-answer: correct
        for i in 0..<singleAnswerCorrect {
            let question = makeSingleAnswerQuestion(id: "singleCorrect\(i)", correctIndex: 0)
            questions.append(makeCorrectlyAnsweredQuestion(from: question))
        }

        // Single-answer: wrong
        for i in 0..<singleAnswerWrong {
            let question = makeSingleAnswerQuestion(id: "singleWrong\(i)", correctIndex: 0)
            questions.append(makeIncorrectlyAnsweredQuestion(from: question))
        }

        return AttemptedExam(
            examId: examId,
            questions: questions,
            status: .finished,
            dateAttempted: Date(),
            duration: 300
        )
    }
}
