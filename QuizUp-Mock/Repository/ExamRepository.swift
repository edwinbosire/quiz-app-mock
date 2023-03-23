//
//  ExamRepository.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 22/03/2023.
//

import Foundation

enum ExamRepositoryErrors: Error {
	case UnableToLoadJSONFile
}

class ExamRepository {
	let exams: [Exam]

	static let shared = ExamRepository()
		private init() {
			self.exams = ExamRepository.generateAllExams()
		}

	static func generateAllExams() -> [Exam] {
		var exams = [Exam]()

		do {
			let allQuestions = try ExamRepository.parseJSONData()

			let examSize: Int = 25
			let numExams = allQuestions.count / examSize

			var x: Int = 0
			for i in 0..<numExams {
				let start = i * examSize
				let end = start + examSize
				let examQuestions = Array(allQuestions[start..<end])
				let anExam = Exam(id: x, questions: examQuestions, status: .unattempted)
				exams.append(anExam)
				x += 1
			}

		} catch {
			print("Failed to generate exams!")
		}
		return exams
	}

	static func mockExam(questions limit: Int = 25) -> Exam {
		let questionBank = try! ExamRepository.parseJSONData()
		let exam = Array(questionBank[0..<limit])
		return Exam(id: 0, questions: exam, status: .unattempted)
	}
}

extension ExamRepository {
	static func parseJSONData() throws -> [Question] {
		guard let jsonURL = Bundle.main.url(forResource: "questions", withExtension: "json") else {
			throw ExamRepositoryErrors.UnableToLoadJSONFile
		}

		do {
			let jsonData = try Data(contentsOf: jsonURL, options: .alwaysMapped)
			let questionData = try JSONDecoder().decode(QuestionData.self, from: jsonData)
			return questionData.data.map { $0.toModel() }
		} catch {
			print("Error decoding JSON data: \(error.localizedDescription)")
			throw ExamRepositoryErrors.UnableToLoadJSONFile
		}
	}
}
