//
//  MainMenuViewModel.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 23/03/2023.
//

import Foundation

class MenuViewModel: ObservableObject {
	private var repository: ExamRepository
	@Published var exams: [ExamViewModel] = []
//	@Namespace var practiceExamListNamespace: Namespace.ID?
	@Published var completedExams: [ExamViewModel]  = []

	@Published var route: Route = .mainMenu
	@Published var isShowingMonitizationPage = false

	public static let shared = MenuViewModel()

	init(repository: ExamRepository = .shared) {
		self.repository = repository
		self.exams = repository.exams.map { ExamViewModel(exam: $0) }
		completedExams = repository.exams.filter { $0.status == .finished }.map { ExamViewModel(exam: $0) }
	}

	func reloadExams() {
		exams = repository.exams.map { ExamViewModel(exam: $0) }
		completedExams = repository.exams.filter { $0.status == .finished }.map { ExamViewModel(exam: $0) }
	}

	func examViewModel(with exam: Exam) -> ExamViewModel {
		 ExamViewModel(exam: exam)
	}

}
