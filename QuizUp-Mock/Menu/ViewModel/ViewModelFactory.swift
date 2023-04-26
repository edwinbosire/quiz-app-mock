//
//  ViewModelFactory.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 26/04/2023.
//

import Foundation

struct ViewModelFactor {
	private var repository: ExamRepository = .shared

	func buildExamViewModels() async -> [ExamViewModel] {
		do {
			return try await repository.load().map { ExamViewModel(exam: $0) }
		} catch (let error) {
			print("Failed to build ExamViewModels with error: \(error)")
			return []
		}
	}
}
