//
//  PreviewModel.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 26/04/2023.
//

import Foundation

struct PreviewModel {

	static func mockExam(questions limit: Int = 25) async -> Exam {
		guard let questionBank = try? await ExamRepository.parseJSONData() else {
			fatalError("Failed to generate mock exam")
		}
		let exam = Array(questionBank[0..<limit])
		return Exam(id: 0, questions: exam, status: .unattempted)
	}

	static func mockQuestionViewModel() async -> QuestionViewModel {
		let mockExam = await Self.mockExam(questions: 1)
		return await QuestionViewModel(question: mockExam.questions[0])
	}

	static func mockExamViewModel() async -> ExamViewModel {
		let exam = await PreviewModel.mockExam()
		return await ExamViewModel(exam: exam)
	}
}
