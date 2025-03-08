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
	let question: Question
	let index: Int
	var questionTitle: String { question.title }
	var hint: String { question.hint ?? ""}
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
	var selectedChoices = Set<Choice>()
	var shouldAllowDeselect = false

	var isAnsweredCorrectly: Bool {
		guard isAnswered else { return false }
		return selectedChoices.filter({$0.isAnswer == false}).count > 0 ? false : true
	}

	var isAnswered: Bool {
		selectedChoices.count == answers.count || answersAutoSelected
	}

	var allowChoiceSelection: Bool {
		(selectedChoices.count < answers.count) && !answersAutoSelected
	}

	@Published var answerState = [Choice : AnswerState]()
	@Published var attempts: Int = 0
	@Published private(set) var showHint: Bool = false
	@Published var bookmarked: Bool = false

	var owner: QuestionOwner?

	private var answersAutoSelected: Bool = false
	var allAnswersSelected: Bool {
		selectedChoices.count == answers.count
	}

	init(question: Question, owner: QuestionOwner? = nil, selectedAnswers: [Choice] = [], index: Int = 0) {
		self.question = question
		self.owner = owner
		self.selectedChoices = Set(selectedAnswers)
		self.index = index
		choices.forEach { answerState[$0] = .notAttempted }
	}

	func state(for answer: Choice) -> AnswerState {
		answerState[answer] ?? .notAttempted
	}

	func selected(_ choice: Choice) {

		guard allowChoiceSelection else {
			fatalError("Allowing the user to select more answers than the question allows is not supported")
		}

		// 1. Handle answer deselection
		if selectedChoices.contains(choice) && shouldAllowDeselect {
			guard let index = selectedChoices.firstIndex(where: {$0 == choice}) else { return }
			selectedChoices.remove(at: index)
			answerState[choice] = .notAttempted
			attempts += 1

			// User could still have other choices selected
			// consider this before showing/hiding hint
			showHint = selectedChoices.filter({$0.isAnswer == false}).count > 0 ? true : false
			return
		}

		selectedChoices.insert(choice)
		answerState[choice] = choice.isAnswer ? .correct : .wrong

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
				self.highlightCorrectAnswers()
				self.attempts += 1
				Task{ @MainActor in
					await self.owner?.allowProgressToNextQuestion()
				}
		}

		// if any selected answer is wrong, show hint
		showHint = selectedChoices.filter({$0.isAnswer == false}).count > 0 ? true : false
	}

#warning("This potentially erase the users selected answers")
	private func highlightCorrectAnswers() {

		answersAutoSelected = true
		choices.forEach { choice in
			if choice.isAnswer {
				answerState[choice] = .correct
			}
		}
	}

	func reset() {
		choices.forEach { answerState[$0] = .notAttempted }
		selectedChoices.removeAll()
		answerState.removeAll()
		showHint = false
		attempts = 0
		answersAutoSelected = false
	}
}

extension QuestionViewModel {
	static func mock() async -> QuestionViewModel {
		await PreviewModel.mockQuestionViewModel()
	}

	static func empty() -> QuestionViewModel {
		QuestionViewModel(question: Question.empty())
	}
}
