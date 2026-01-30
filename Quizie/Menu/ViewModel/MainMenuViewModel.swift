//
//  MainMenuViewModel.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 23/03/2023.
//

import Foundation
import Combine

@MainActor
class MenuViewModel: ObservableObject {
	private let repository: ExamRepository = .shared
	@Published var mockExamsViewModels: [ExamViewModel] = []
	@Published var attemptedExams: [AttemptedExam]  = []

	@Published var isShowingMonitizationPage = false
	@Published var isSearching: Bool = false
	@Published var searchQuery: String = ""
	@Published var debouncedQuery: String = ""

	public static let shared = MenuViewModel()
	private var bag = Set<AnyCancellable>()
	var handbookViewModel = HandbookViewModel()
	@Published private(set) var results: [ExamResultViewModel] = []

	init() {

		$searchQuery
			.removeDuplicates()
			.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
			.sink(receiveValue: { [weak self] value in
				self?.debouncedQuery = value
			})
			.store(in: &bag)

		Task {
			await loadExams()
		}
	}

	func loadExams() async {
		if let viewModels = try? await repository.loadMockExams().map({ ExamViewModel(exam: $0) }) {
			mockExamsViewModels = viewModels
		}

		if let exams = try? await repository.loadAttemptedExams() {
			attemptedExams = exams.sorted(by: {$0.dateAttempted > $1.dateAttempted})
		}
	}

	func loadResults() async {
		if let examResults = try? await repository.loadResults() {
			results = examResults
			print("Loaded \(results.count) results")
		}
	}
}
