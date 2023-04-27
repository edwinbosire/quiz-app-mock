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
	let question: Question
	let index: Int

	var title: String { question.title }
	var hint: String { question.hint ?? ""}
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
	var isAnsweredCorrectly: Bool {
		guard selectedAnswers.count == answers.count else { return false }
		for selectedAnswer in selectedAnswers {
			if answers.contains(selectedAnswer) == false { return false }
		}
		return true
	}
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

	func reset() {
		options.forEach { answerState[$0] = .notAttempted }
		selectedAnswers = []
		answerState = [:]
		showHint = false
		attempts = 0
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
			showHint.toggle()
			return

		} else if selectedAnswers.count < answers.count {
			selectedAnswers.append(answer)
			answerState[answer] = answer.isAnswer ? .correct : .wrong
			if answers.contains(answer) {
				if allQuesionsAnswered {
					owner?.progressToNextQuestions()
				}
			} else {
				highlightCorrectAnswers()
				attempts += 1
				owner?.allowProgressToNextQuestion()
				showHint.toggle()
			}
		} else {
			showHint.toggle()
		}
	}

	private func highlightCorrectAnswers() {
		answers.forEach { answer in
			answerState[answer] = .correct
		}
	}

	static func mock() -> QuestionViewModel {
		let mockExam = PreviewModel().examMock()
		return QuestionViewModel(question: mockExam.questions[0])
	}
}
