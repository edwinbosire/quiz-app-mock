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
	@State var isShowingMonitizationPage = false
	@Namespace var namespace

	var body: some Scene {
		WindowGroup {
			switch route {
				case .mainMenu, .progressReport, .settings, .monetization:
					MainMenu(route: $route, namespace: namespace)
						.sheet(isPresented: $isShowingMonitizationPage, content: {
							MonitizationView(route: $route)
						})
						.onChange(of: route) { newValue in
							if route == .monetization {
								isShowingMonitizationPage = true
							} else {
								isShowingMonitizationPage = false
							}
						}
						.environmentObject(menuViewModel)

				case .mockTest:
					ExamView(viewModel: mockExamViewModel, route: $route, namespace: namespace)
				case .handbook:
					HanbookMainMenu()
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
