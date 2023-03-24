//
//  ExamRepository.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 22/03/2023.
//

import Foundation

enum ExamRepositoryErrors: Error {
	case UnableToLoadQuestionsJSONFile
	case UnableToLoadExplanationJSONFile
	case UnableToDecodeJSONFile
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
		guard let questionsJSONURL = Bundle.main.url(forResource: "questions", withExtension: "json") else {
			throw ExamRepositoryErrors.UnableToLoadQuestionsJSONFile
		}

		guard let explanationJSONURL = Bundle.main.url(forResource: "explanation", withExtension: "json") else {
			throw ExamRepositoryErrors.UnableToLoadExplanationJSONFile
		}


		do {
			let explanationsJSON = try Data(contentsOf: explanationJSONURL, options: .alwaysMapped)
			let explanations = try JSONDecoder().decode(ExplanationsDTOWrapper.self, from: explanationsJSON)

			let questionsJSON = try Data(contentsOf: questionsJSONURL, options: .alwaysMapped)
			let questions = try JSONDecoder().decode(QuestionData.self, from: questionsJSON)

			return questions.data.map { question in
				if let explanationDTO = explanations.data.first(where: { $0.id == Int(question.bookSectionId)}) {
					return question.toModel(with: explanationDTO.explanation)
				}
				return question.toModel(with: nil)

			}
		} catch {
			print("Error decoding JSON data: \(error.localizedDescription)")
			throw ExamRepositoryErrors.UnableToDecodeJSONFile
		}
	}
}
