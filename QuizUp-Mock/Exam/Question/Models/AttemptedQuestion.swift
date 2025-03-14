//
//  AttemptedQuestion.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 11/03/2025.
//

import Foundation

struct AttemptedQuestion: Codable, Hashable {
	enum State: Codable {
		case correct
		case wrong
		case notAttempted
	}

	let id: String
	let question: Question
	var selectedChoices: [Choice: AttemptedQuestion.State]
	var bookmarked: Bool = false

	var isAnsweredCorrectly: Bool {
		selectedChoices.values.allSatisfy({$0 == .correct})
	}

	/// Fully answered != AnsweredCorrectly, it just means that the user has selected all the answers required
	var isFullyAnswered: Bool {
		selectedChoices.count == choices.filter({$0.isAnswer}).count
	}

	init(from question: Question, selectedChoices: [Choice: AttemptedQuestion.State] = [:], bookmarked: Bool = false) {
		self.id = question.id
		self.question = question
		self.selectedChoices = selectedChoices
		self.bookmarked = bookmarked
	}

	init(from question: Question) {
		self.id = question.id
		self.question = question
		self.selectedChoices = [:]
		self.bookmarked = false
	}

	mutating func updateSelected(_ choice: Choice, state: AttemptedQuestion.State) {
		self.selectedChoices[choice] = state
	}

	mutating func updateSelectedChoices(_ selected: [Choice: AttemptedQuestion.State]) {
		self.selectedChoices = selected
	}

	mutating func bookmark() {
		self.bookmarked.toggle()
	}

	var title: String {
		question.title
	}

	var hint: String {
		question.hint  ?? "N/A"
	}

	var choices: [Choice] {
		question.choices
	}

	static func empty() -> AttemptedQuestion {
		AttemptedQuestion(from: Question.empty())
	}

}
