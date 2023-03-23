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

//	init(from decoder: Decoder) throws {
//		do {
//			let container = try decoder.container(keyedBy: CodingKeys.self)
//			let questionId = try container.decode(String.self, forKey: .questionId)
//			let bookSectionId = try container.decode(String.self, forKey: .bookSectionId)
//			let category = try container.decode(String.self, forKey: .category)
//			let question = try container.decode(String.self, forKey: .question)
//			let year = try container.decodeIfPresent(String.self, forKey: .year)
//			let choices = try container.decode([String].self, forKey: .choices)
//			let correct = try container.decode([String].self, forKey: .correct)
//			let explanation = try container.decode(Explanation.self, forKey: .explanation)
//
//
//			self.questionId = questionId
//			self.bookSectionId = bookSectionId
//			self.category = category
//			self.question = question
//			self.year = year
//			self.choices = choices
//			self.correct = correct
//			self.explanation = explanation
//
//return
//		} catch {
//			print("error")
//		}
//
//		self.questionId = "questionId"
//		self.bookSectionId = "bookSectionId"
//		self.category = "category"
//		self.question = "question"
//		self.year = "year"
//		self.choices = ["choices"]
//		self.correct = ["1"]
//		self.explanation = Explanation(link: "")
//
//	}
}

extension QuestionDTO {
	func toModel() -> Question {
		let correctAnswers = self.correct.compactMap { Int($0) }
		let answers = self.choices.enumerated().map { index, answer in Answer(title: answer, isAnswer: correctAnswers.contains(index))}

		return Question(id: questionId,
						sectionId: bookSectionId,
						title: question,
						hint: self.explanation.link,
						answers: answers)
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

struct Question: Hashable {
	let id: String
	let sectionId: String
	let title: String
	let hint: String?
	let answers: [Answer]
}

struct Answer: Hashable {
	let title: String
	let isAnswer: Bool

	init(title: String, isAnswer: Bool = false) {
		self.title = title
		self.isAnswer = isAnswer
	}
}
