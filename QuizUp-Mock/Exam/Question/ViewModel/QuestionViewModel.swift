//
//  Question.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 12/03/2023.
//

import Foundation

// This is for a single question in an exam of 25 questions.

@MainActor
class QuestionViewModel: ObservableObject, @preconcurrency Identifiable {
	var id: String {
		question.title
	}

	var question: AttemptedQuestion
	let index: Int
	var questionTitle: String { question.title }
	var hint: String { question.hint }
	var choices: [Choice] { question.choices }
	var answers: [Choice] { question.choices.compactMap { $0.isAnswer ? $0 : nil }}
	var prompt: String {
		if answers.count == 1 {
			return "Please select ONE answer"
		} else if answers.count == 2 {
			return "Please select TWO answers"
		}
		return "Please select MULTIPLE answers"
	}

	var shouldAllowDeselect = false

	var isAnsweredCorrectly: Bool {
		question.isAnsweredCorrectly
	}

	var isFullyAnswered: Bool {
		question.isFullyAnswered
	}

	var allowChoiceSelection: Bool {
		isFullyAnswered == false
	}

	@Published var selectedChoices: [Choice : AttemptedQuestion.State] = [:] {
		didSet {
			question.updateSelectedChoices(selectedChoices)
		}
	}
	@Published var attempts: Int = 0
	@Published private(set) var showHint: Bool = false
	@Published var bookmarked: Bool = false {
		didSet {
			question.bookmark()
		}
	}

	var owner: QuestionOwner?

	var allAnswersSelected: Bool {
		selectedChoices.count == answers.count
	}

	init(question: AttemptedQuestion, owner: QuestionOwner? = nil, selectedChoices: [Choice: AttemptedQuestion.State] = [:], index: Int = 0) {
		self.question = question
		self.owner = owner
		self.selectedChoices = selectedChoices
		self.index = index
	}

	func state(for answer: Choice) -> AttemptedQuestion.State {
		if let selectedChoice = selectedChoices[answer] {
			return selectedChoice
		}

		if !isAnsweredCorrectly {
			return answer.isAnswer ? .correct : .notAttempted
		}

		return .notAttempted
	}

	func selected(_ choice: Choice) {

		guard allowChoiceSelection else {
			fatalError("Allowing the user to select more answers than the question allows is not supported")
		}

		// 1. Handle answer deselection
		if let selectedAnswerState = selectedChoices[choice], shouldAllowDeselect {
			guard let index = question.choices.firstIndex(where: {$0 == choice}) else { return }
			selectedChoices[choice] = nil
			question.updateSelected(choice, state: .notAttempted)
			attempts += 1

			// User could still have other choices selected
			// consider this before showing/hiding hint
			showHint = selectedChoices.values.allSatisfy { $0 == .correct } == false
			return
		}

		selectedChoices[choice] = choice.isAnswer ? .correct : .wrong
		question.updateSelected(choice, state: choice.isAnswer ? .correct : .wrong)

		///
		/// ------------------------| allAnswersSelected
		///				 | YES  |  NO     |
		/// Choice.isAnswer  |---------|----------|
		/// 		 YES |   ⏭️    |	⏯️	|
		/// 			 |---------|----------|
		/// 		  NO |   🚩   |    🚦	|
		/// 			 |---------|----------|
		/// 		⏭️ Proceed to next question
		/// 		⏯️ Allow user to select more choices
		/// 		🚩 Display hint, allow  user to proceed to next question
		/// 		🚦 Show hint, auto-select correct answers
		switch (choice.isAnswer, allAnswersSelected) {
			case (true, true):
				Task { @MainActor in
					await owner?.progressToNextQuestions()
				}
			case (true, false):
				break
			case (false, true):
				fallthrough
			case (false, false):
				self.attempts += 1
				Task{ @MainActor in
					await self.owner?.allowProgressToNextQuestion()
				}
		}

		// if any selected answer is wrong, show hint
		showHint = selectedChoices.values.allSatisfy { $0 == .correct } == false
	}

	func reset() {
		selectedChoices.removeAll()
		showHint = false
		attempts = 0
	}

	func finish() -> AttemptedQuestion {
		AttemptedQuestion(from: question.question, selectedChoices: selectedChoices, bookmarked: bookmarked)
	}
}

extension QuestionViewModel {
	static func mock() async -> QuestionViewModel {
		await PreviewModel.mockQuestionViewModel()
	}

	static func empty() -> QuestionViewModel {
		QuestionViewModel(question: AttemptedQuestion.empty())
	}
}
