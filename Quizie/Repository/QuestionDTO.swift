//
//  QuestionDTO.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 13/03/2023.
//

import Foundation

/// A model representing a multiple-choice question.
struct QuestionDTO: Codable {

	/// The unique identifier of the question.
	var questionId: String

	/// The identifier of the section of a book that the question belongs to.
	var bookSectionId: String

	/// The category of the question (e.g. history, culture, etc.).
	var category: String

	/// The text of the question.
	var question: String

	/// The year or era that the question pertains to (if applicable).
	var year: String?

	/// An array of possible answer choices for the question.
	var choices: [String]

	/// An array of index(es) of the correct answer(s) in the `choices` array. Note that the index starts from 0.
	var correct: [String]

	/// An object providing an explanation for the answer, including an optional link to additional resources.
	var explanation: Explanation

	enum CodingKeys: String, CodingKey {
		case questionId = "question_id"
		case bookSectionId = "book_section_id"
		case category
		case question
		case year
		case choices
		case correct
		case explanation
	}
}

extension QuestionDTO {
	func toModel(with hint: String?) -> Question {
		let answers = self.correct.compactMap { Int($0) }
		let choices = self.choices.enumerated().map { index, title in
			Choice(title: title, isAnswer: answers.contains(index))
		}.shuffled()

		return Question(id: questionId,
						sectionId: bookSectionId,
						title: question,
						hint: hint,
						choices: choices)
	}
}

/// An object representing the explanation for the question.
struct Explanation: Codable {
	/// An optional link to additional resources that provide more information about the answer.
	let link: String?
}

struct QuestionData: Codable {
	let data: [QuestionDTO]
}

struct Question: Codable, Hashable {
	let id: String
	let sectionId: String
	let title: String
	let hint: String?
	let choices: [Choice]

	enum CodingKeys: String, CodingKey {
		case id
		case sectionId
		case title
		case hint
		case choices = "answers"
	}

	static func empty() -> Question {
		.init(id: "", sectionId: "", title: "", hint: nil, choices: [])
	}
}

extension Question: Identifiable {}

struct Choice: Codable, Hashable {
	let title: String
	let isAnswer: Bool

	init(title: String, isAnswer: Bool = false) {
		self.title = title
		self.isAnswer = isAnswer
	}

	init(_ title: String) {
		self.init(title: title, isAnswer: false)
	}

}

extension Choice: Identifiable {
	var id: String { self.title }
}

struct ExplanationsDTOWrapper: Codable {
	let data: [ExplanationsDTO]
}

struct ExplanationsDTO: Codable {
	let id: Int
	let explanation: String
}

//struct ExplanationData {
//	let id: Int
//	let explanation: String
//}
