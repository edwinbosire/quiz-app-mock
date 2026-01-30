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
		let questions = Array(questionBank[0..<limit])
		return Exam(id: 0, questions: questions)
	}

	static func mockQuestionViewModel() async -> QuestionViewModel {
		let mockExam = await Self.mockExam(questions: 1)
		let attemptedQuestion = AttemptedQuestion(from: mockExam.questions[0])

		return await QuestionViewModel(question: attemptedQuestion)
	}

	static func mockExamViewModel() async -> ExamViewModel {
		let exam = await PreviewModel.mockExam()
		if exam.questions.isEmpty {
			fatalError(#function)
		}
		return await ExamViewModel(exam: exam)
	}
}
