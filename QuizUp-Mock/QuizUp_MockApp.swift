//
//  QuizUp_MockApp.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 29/10/2021.
//

import SwiftUI

@main
struct QuizUp_MockApp: App {
	@ObservedObject private var mockExamViewModel = ExamViewModel.mock()
	@StateObject private var menuViewModel = MenuViewModel.shared
	@State var route: Route = .mainMenu
	@State var isShowingProgressReport = false
	@State var isShowingMonitizationPage = false
	@Namespace var namespace

	var body: some Scene {
		WindowGroup {
			switch route {
				case .mainMenu, .progressReport, .settings, .monetization:
					MainMenu(route: $route, namespace: namespace)
						.sheet(isPresented: $isShowingProgressReport) {
							ProgressReport(route: $route)
						}
						.sheet(isPresented: $isShowingMonitizationPage, content: {
							MonitizationView(route: $route)
						})
						.onChange(of: route) { newValue in
							if route == .progressReport {
								isShowingProgressReport = true
							} else if route == .monetization {
								isShowingMonitizationPage = true
							} else {
								isShowingProgressReport = false
								isShowingMonitizationPage = false
							}
						}
						.environmentObject(menuViewModel)

				case .mockTest:
					ExamView(viewModel: mockExamViewModel, route: $route, namespace: namespace)
				case .handbook:
					HanbookMainMenu(chapter: Book().chapters[0])
				case .questionbank:
					QuestionBankView(route: $route)
			}
		}
    }
}

enum Route: Equatable {
	case mainMenu
	case mockTest(testId: Int)
	case handbook(chapter: Int)
	case questionbank
	case progressReport
	case settings
	case monetization
}
