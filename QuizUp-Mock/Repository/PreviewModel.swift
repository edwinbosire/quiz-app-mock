//
//  PreviewModel.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 26/04/2023.
//

import Foundation

struct PreviewModel {

	func mockExam(questions limit: Int = 25) async -> Exam {
		do {
			let questionBank = try await ExamRepository.parseJSONData()
			let exam = Array(questionBank[0..<limit])
			return Exam(id: 0, questions: exam, status: .unattempted)
		} catch {
			print("Failed to generate mock exam")
			return Exam(id: 00, questions: [], status: .unattempted)
		}
	}

	func mockQuestionViewModel() async -> QuestionViewModel {
		let mockExam = await mockExam(questions: 1)
		return QuestionViewModel(question: mockExam.questions[0])
	}

	func mockExamViewModel() async -> ExamViewModel {
		let exam = examMock()
		return ExamViewModel(exam: exam)
	}

	func examMock() -> Exam {
		Exam.mock()
	}
}
