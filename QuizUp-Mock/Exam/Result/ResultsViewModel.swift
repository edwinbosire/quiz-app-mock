//
//  ResultsViewModel.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 26/04/2023.
//

import Foundation

class ResultsViewModel: ObservableObject {
	private var exam: ExamResult?
	let repository: ExamRepository

	lazy var questions: [Question] = {
		if let exam = exam {
			return exam.questions
		}
		return []
	}()

	init(repository: ExamRepository, exam id: Int) {
		self.repository = repository
		Task {
			let results = try? await repository.loadResults()
			exam = results?.first(where: { $0.examId == id})
		}
	}

}
