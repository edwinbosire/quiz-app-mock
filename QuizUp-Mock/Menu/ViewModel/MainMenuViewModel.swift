//
//  MainMenuViewModel.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 23/03/2023.
//

import Foundation

class MenuViewModel: ObservableObject {
	private let viewModelFactor = ViewModelFactor()
	@Published var exams: [ExamViewModel] = []
	@Published var completedExams: [ExamViewModel]  = []

	@Published var route: Route = .mainMenu
	@Published var isShowingMonitizationPage = false

	public static let shared = MenuViewModel()

	init() {
		Task {
			exams = await viewModelFactor.buildExamViewModels()
			completedExams = exams.filter { $0.exam.status == .finished }
		}
	}

	func reloadExams() async {
		exams = await viewModelFactor.buildExamViewModels()
		completedExams = exams.filter { $0.exam.status == .finished }
	}
}
