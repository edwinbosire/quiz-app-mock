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
	case ExamNotFound
	case UnableToLoadExamsFromStorage
	case NoExamsFoundInStorage
	case UnableToSaveExamsToStorage

}

protocol Repository {
	func load() async throws -> [Exam]
	func load(exam withId: Int) async throws -> Exam

	func save(exam: Exam) async throws

	func reset()
}

class ExamRepository: Repository {
	private var defaults: UserDefaults = UserDefaults.standard
	static let shared = ExamRepository()
	let savedExamsKey = "exams"

	func load(exam withId: Int) async throws -> Exam {
		var exams = try await load()
		guard let exam = exams.first(where: { $0.id == withId }) else {
			throw ExamRepositoryErrors.ExamNotFound
		}
		return exam
	}

	func load() async throws -> [Exam] {
		print("Loading all exams from disk")

		// if its the first run of the app, generate exams
		guard let savedExams = defaults.object(forKey: savedExamsKey) as? Data else {
			let exams = try await generateAllExams()
			try await saveAll(exams: exams)
			return exams
		}

		do {
			return try JSONDecoder().decode([Exam].self, from: savedExams)
		} catch {
			print("Failed to load exams")
			throw ExamRepositoryErrors.UnableToLoadExamsFromStorage
		}
	}

	func save(exam: Exam) async throws {
		var allExams = try await load()
		guard let ndx = allExams.firstIndex(where: { $0.id == exam.id }) else {
			print("failed to find exam to save: \(exam)")
			throw ExamRepositoryErrors.ExamNotFound
		}
		allExams[ndx] = exam
		try await saveAll(exams: allExams)
		print("Saved Exam \(exam)")
	}

	private func saveAll(exams: [Exam]) async throws {
		if let exams = try? JSONEncoder().encode(exams) {
			let defaults = UserDefaults.standard
			defaults.set(exams, forKey: savedExamsKey)
			print("saved \(exams.count) exams")
		} else {
			print("Failed to save exam.")
			throw ExamRepositoryErrors.UnableToSaveExamsToStorage
		}
	}

	func reset() {
		UserDefaults.standard.set(nil, forKey: savedExamsKey)
	}
}

extension ExamRepository {
	func generateAllExams() async throws -> [Exam] {
		print("Generating all exams from file")
		var exams = [Exam]()

		do {
			let allQuestions = try await ExamRepository.parseJSONData()

			let examSize: Int = 25
			let numExams = allQuestions.count / examSize

			var examId: Int = 0
			for i in 0..<numExams {
				let start = i * examSize
				let end = start + examSize
				let examQuestions = Array(allQuestions[start..<end])
				let anExam = Exam(id: examId, questions: examQuestions, status: .unattempted)
				exams.append(anExam)
				examId += 1
			}

		} catch {
			print("Failed to generate exams!")
		}
		return exams
	}
}

extension ExamRepository {
	static func parseJSONData() async throws -> [Question] {
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
