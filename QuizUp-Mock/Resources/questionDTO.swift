//
//  questionDTO.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 13/03/2023.
//

import Foundation

struct QuestionWrapperDTO: Decodable {
	let data: [QuestionDTO]
}
struct QuestionDTO: Decodable {
	let question_id: String
	let book_section_id: String
	let question: String
	let year: String
	let choices: [String]
	let correct: [String]


	static func loadAllQuestions() -> [Question]? {
		if let path = Bundle.main.path(forResource: "questions", ofType: "json") {
			do {

				let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)

				if let jsonResult = try? JSONDecoder().decode(QuestionWrapperDTO.self, from: data) {

					return jsonResult.data.map { q in
						let correctAnswers = q.correct.compactMap { Int($0) }
						let answers = q.choices.enumerated().map { index, answer in Answer(title: answer, isAnswer: correctAnswers.contains(index))}
						return Question(title: q.question, options: answers)
					}
				}
			} catch let error {
				print("parse error: \(error.localizedDescription)")
			}
		} else {
			print("Invalid filename/path.")
		}
		return []
	}

}
