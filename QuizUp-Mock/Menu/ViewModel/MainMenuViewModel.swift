//
//  MainMenuViewModel.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 23/03/2023.
//

import Foundation

@MainActor
class MenuViewModel: ObservableObject {
	private let viewModelFactor = ViewModelFactor()
	@Published var exams: [ExamViewModel] = []
	@Published var completedExams: [ExamViewModel]  = []

	@Published var route: Route = .mainMenu
	@Published var isShowingMonitizationPage = false
	@Published var isSearching: Bool = false
	@Published var searchQuery: String = ""
	
	public static let shared = MenuViewModel()

	var handbookViewModel = HandbookViewModel()
	init() {
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
