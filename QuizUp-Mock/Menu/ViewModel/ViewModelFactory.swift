//
//  ViewModelFactory.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 26/04/2023.
//

import Foundation

@MainActor
struct ViewModelFactory {
	private var repository: ExamRepository = .shared

	func buildExamViewModels() async -> [ExamViewModel] {
		do {
			return try await repository
				.loadExams()
				.map(ExamViewModel.init)
		} catch (let error) {
			print("Failed to build ExamViewModels with error: \(error)")
			return []
		}
	}
}
