//
//  MainMenuViewModel.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 23/03/2023.
//

import Foundation

class MenuViewModel: ObservableObject {
	private var repository: ExamRepository
	var exams: [Exam]
//	@Namespace var practiceExamListNamespace: Namespace.ID?

	@Published var route: Route = .mainMenu
	@Published var isShowingMonitizationPage = false

	public static let shared = MenuViewModel()

	init(repository: ExamRepository = .shared) {
		self.repository = repository
		self.exams = repository.exams
	}

	func examViewModel(with exam: Exam) -> ExamViewModel {
		 ExamViewModel(exam: exam)
	}

}
