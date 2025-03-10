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
	private let viewModelFactory = ViewModelFactory()
	private let repository: ExamRepository = .shared
	@Published var exams: [ExamViewModel] = []
	@Published var completedExams: [ExamViewModel]  = []

	@Published var isShowingMonitizationPage = false
	@Published var isSearching: Bool = false
	@Published var searchQuery: String = ""
	@Published var debouncedQuery: String = ""

	public static let shared = MenuViewModel()
	private var bag = Set<AnyCancellable>()
	var handbookViewModel = HandbookViewModel()
	@Published private(set) var results: [ExamResult] = []

	init() {

		$searchQuery
			.removeDuplicates()
			.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
			.sink(receiveValue: { [weak self] value in
				self?.debouncedQuery = value
			})
			.store(in: &bag)

		Task {
			await reloadExams()
		}
	}

	@discardableResult func reloadExams() async -> [ExamResult] {
		let allExams = await viewModelFactory.buildExamViewModels()
		exams = allExams.filter { $0.exam.status == .unattempted }
		completedExams = exams.filter { $0.exam.status == .finished || $0.exam.status == .didNotFinish}

		do {
			results = try await repository.loadResults()
		} catch {
			results = []
		}
		return results

	}
}
