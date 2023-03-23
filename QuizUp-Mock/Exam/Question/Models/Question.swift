//
//  Question.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 12/03/2023.
//

import Foundation

// This is for a single question in an exam of 25 questions.

class QuestionViewModel: ObservableObject, Identifiable {
	var id: Int
	private let question: Question
	let index: Int

	var title: String { question.title }
	var hint: String { "This is a sample hint for a single question, it can be as long or short as one wishes, as a matter of fact, it can span multiple paragraphs "}// { question.hint }
	var options: [Answer] { question.answers }
	var answers: [Answer] { question.answers.compactMap { $0.isAnswer ? $0 : nil }}
	var prompt: String {
		if answers.count == 1 {
			return "Please select ONE answer"
		} else if answers.count == 2 {
			return "Please select TWO answers"
		}
		return "Please select MULTIPLE answers"
	}
	var selectedAnswers = [Answer]()
	var shouldAllowDeselect = false

	@Published var answerState = [Answer : AnswerState]()
	@Published var attempts: Int = 0
	@Published var showHint: Bool = false

	var owner: QuestionOwner?
	private var allQuesionsAnswered: Bool {
		selectedAnswers.count == answers.count
	}

	init(question: Question, index: Int = 0, owner: QuestionOwner? = nil) {
		self.question = question
		self.index = index
		self.owner = owner
		self.id = index
		options.forEach { answerState[$0] = .notAttempted }
	}

	func state(for answer: Answer) -> AnswerState {
		answerState[answer] ?? .notAttempted
	}

	func selected(_ answer: Answer) -> Void {
		if selectedAnswers.contains(answer) && shouldAllowDeselect {
			guard let index = selectedAnswers.firstIndex(where: {$0 == answer}) else { return }
			selectedAnswers.remove(at: index)
			answerState[answer] = .notAttempted
			attempts = 0
			return
		} else if selectedAnswers.count < answers.count {
			selectedAnswers.append(answer)

			if answers.contains(answer) {
				answerState[answer] = .correct
				if allQuesionsAnswered {
					owner?.progressToNextQuestions()
				}
			} else {
				highlightCorrectAnswers()
				answerState[answer] = .wrong
				attempts += 1
				owner?.allowProgressToNextQuestion()
			}
		}
	}

	private func highlightCorrectAnswers() {
		showHint = true
		answers.forEach { answer in
			answerState[answer] = .correct
		}
	}

	func reset() {
		options.forEach { answerState[$0] = .notAttempted }
		selectedAnswers = [Answer]()
		showHint = false
		attempts = 0
	}

	static func mock() -> QuestionViewModel {
		let mockExam = ExamRepository.mockExam(questions: 5)
		return QuestionViewModel(question: mockExam.questions[0])
	}
}
