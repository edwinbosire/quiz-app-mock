//
//  ResultsViewModel.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 26/04/2023.
//

import Foundation

class ResultsViewModel: ObservableObject {
	let examId: Int
	var exam: Exam?
	let repository: ExamRepository

	lazy var questions: [Question] = {
		if let exam = exam {
			return exam.questions
		}
		return []
	}()

	init(examId: Int, repository: ExamRepository) {
		self.examId = examId
		self.repository = repository
		Task {
			self.exam = try? await repository.load(exam: examId)
		}
	}
}
