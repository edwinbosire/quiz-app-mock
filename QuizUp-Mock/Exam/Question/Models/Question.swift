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
		QuestionViewModel(question: Question.mockQuestion1())
	}
}

struct Question {
	let title: String
	let hint: String
	let answers: [Answer]

	init(title: String, hint: String = "", options: [Answer]) {
		self.title = title
		self.hint = hint
		self.answers = options
	}
}

struct Answer: Hashable {
	let title: String
	let isAnswer: Bool

	init(title: String, isAnswer: Bool = false) {
		self.title = title
		self.isAnswer = isAnswer
	}
}

extension Question {
	static func mockQuestion1() -> Question {
		let answers = [
			"Treating others with fairness",
			"Looking after yourself and family",
			"Looking after the environment",
			"Driving a car"
		]
		let options = answers.enumerated().map { index, value in Answer(title: value, isAnswer: index == 3)}
		let hint = "Driving a car is NOT one of the fundamental principles of British life."

		return Question(title: "What is not a fundamental principle of British life?",
						hint: hint,
						options: options)
	}

	static func mockQuestion2() -> Question {
		let answers = [
			"The Prime Minister",
			"The Monarch",
			"The Shadow Cabinet",
			"The Speaker"
		]
		let options = answers.enumerated().map { index, value in Answer(title: value, isAnswer: index == 1 )}
		let hint = "Life peers are appointed by the monarch on the advice of the Prime Minister.."

		return Question(title: "Who appoints “Life peers”?",
						hint: hint,
						options: options)
	}

	static func mockQuestion3() -> Question {
		let answers = [
			"Leonardo DiCaprio",
			"Colin Firth",
			"Tilda Swinton",
			"Jacky Stewart"
		]

		let options = answers.enumerated().map { index, value in Answer(title: value, isAnswer: (index == 1 || index == 2))}
		let hint = "Recent British actors to have won Oscars include Colin Firth, Sir Anthony Hopkins, Dame Judi Dench, Kate Winslet and Tilda Swinton."

		return Question(title: "Which Two British film actors have recently won Oscars?",
						hint: hint,
						options: options)
	}

}
