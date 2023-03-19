//
//  QuizUp_MockApp.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 29/10/2021.
//

import SwiftUI

@main
struct QuizUp_MockApp: App {
	@ObservedObject var viewModel = ExamViewModel.mock()
	@State var route: Route = .mainMenu
	@State var isShowingProgressReport = false
	@State var isShowingSettings = false
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
						.sheet(isPresented: $isShowingSettings) {
							SettingsView(route: $route)
						}
						.sheet(isPresented: $isShowingMonitizationPage, content: {
							MonitizationView(route: $route)
						})
						.onChange(of: route) { newValue in
							if route == .progressReport {
								isShowingProgressReport = true
							} else if route == .settings {
								isShowingSettings = true
							} else if route == .monetization {
								isShowingMonitizationPage = true
							}else {
								isShowingProgressReport = false
								isShowingSettings = false
							}
						}
				case .mockTest:
					ExamView(viewModel: viewModel, route: $route, namespace: namespace)
				case .handbook:
					HanbookMainMenu(route: $route)
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
