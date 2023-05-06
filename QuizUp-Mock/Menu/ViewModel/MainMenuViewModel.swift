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
	private let viewModelFactor = ViewModelFactor()
	@Published var exams: [ExamViewModel] = []
	@Published var completedExams: [ExamViewModel]  = []

	@Published var route: Route = .mainMenu
	@Published var isShowingMonitizationPage = false
	@Published var isSearching: Bool = false
	@Published var searchQuery: String = ""
	@Published var debouncedQuery: String = ""

	public static let shared = MenuViewModel()
	private var bag = Set<AnyCancellable>()
	var handbookViewModel = HandbookViewModel()
	init() {

		$searchQuery
			.removeDuplicates()
			.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
			.sink(receiveValue: { [weak self] value in
				self?.debouncedQuery = value
			})
			.store(in: &bag)
//		Task {
//			exams = await viewModelFactor.buildExamViewModels()
//			completedExams = exams.filter { $0.exam.status == .finished }
//		}
	}

	func reloadExams() async {
		exams = await viewModelFactor.buildExamViewModels()
		completedExams = exams.filter { $0.exam.status == .finished }
	}
}
