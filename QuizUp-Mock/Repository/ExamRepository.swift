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
	case UnableToSaveExamsResultToStorage
	case UnableToLoadExamsResultsFromStorage

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
	let examResultsKey = "ExamResultsKey"

	func load(exam withId: Int) async throws -> Exam {
		let exams = try await load()
		guard let exam = exams.first(where: { $0.id == withId }) else {
			throw ExamRepositoryErrors.ExamNotFound
		}
		return exam
	}

	func load() async throws -> [Exam] {
		// if its the first run of the app, generate exams
		guard let savedExams = defaults.object(forKey: savedExamsKey) as? Data else {
			print("Loading all exams from storage")
			let exams = try await generateAllExams()
			try await saveAll(exams: exams)
			return exams
		}
		print("Loading all exams from files on disk")

		do {
			return try JSONDecoder().decode([Exam].self, from: savedExams)
		} catch(let error) {
			print("Failed to load exams: \(error)")
			throw ExamRepositoryErrors.UnableToLoadExamsFromStorage
		}
	}

	func save(exam: Exam) async throws {
		var results: [ExamResult] = []
		if let savedResults = defaults.object(forKey: examResultsKey) as? Data {
			do {
				results = try JSONDecoder().decode([ExamResult].self, from: savedResults)
			} catch(let error) {
				print("Failed to load exams results: \(error)")
			}

		}

		results.append(ExamResult(exam: exam))

		if let examResult = try? JSONEncoder().encode(results) {
			let defaults = UserDefaults.standard
			defaults.set(examResult, forKey: examResultsKey)
			print("saved exam results")
		} else {
			print("Failed to save exam results.")
			throw ExamRepositoryErrors.UnableToSaveExamsResultToStorage
		}
	}

//	func migration() async {
//		let exams = try! await self.load()
//
//		for exam in exams {
//			if exam.status == .finished {
//				try! await save(exam: exam)
//			}
//		}
//	}

	func loadResults() async throws -> [ExamResult] {
		guard let savedExamResults = defaults.object(forKey: examResultsKey) as? Data else {
				return []
		}
		do {
			return try JSONDecoder().decode([ExamResult].self, from: savedExamResults)
		} catch(let error) {
			print("Failed to load exams results: \(error)")
			throw ExamRepositoryErrors.UnableToLoadExamsResultsFromStorage
		}

	}

	private func saveAll(exams: [Exam]) async throws {
		print("Attempting to save \(exams.count) exams")

		if let exams = try? JSONEncoder().encode(exams) {
			let defaults = UserDefaults.standard
			defaults.set(exams, forKey: savedExamsKey)
			print("saved exams")
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
