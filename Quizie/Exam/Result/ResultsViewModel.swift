//
//  ResultsViewModel.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 26/04/2023.
//

import Foundation

//class ResultsViewModel: ObservableObject {
//	private var examResult: ExamResult?
//	let repository: ExamRepository
//
//	lazy var questions: [AttemptedQuestion] = {
//		examResult?.exam.questions ?? []
//	}()
//
//	init(repository: ExamRepository, exam id: Int) {
//		self.repository = repository
//		Task {
//			let results = try? await repository.loadResults()
//			examResult = results?.first(where: { $0.examId == id})
//		}
//	}
//
//}
