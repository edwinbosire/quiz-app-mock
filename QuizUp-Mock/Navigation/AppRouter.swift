//
//  AppRouter.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 05/02/2025.
//

import SwiftUI

struct RouterView<Content: View>: View {
	@EnvironmentObject private var menuViewModel: MenuViewModel

	@State private var isPresentingFullScreen: Bool = false
	@State private var isPresentingSheet: Bool = false

	@StateObject private var router: Router = .init(isPresented: .constant(.none))

	private let content: Content

	init(@ViewBuilder content: @escaping() -> Content) {
		self.content = content()
	}

	var body: some View {
		NavigationStack(path: $router.path) {
			content
				.navigationDestination(for: Destination.self) { destination in
					view(for: destination)
				}
		}
		.sheet($isPresentingSheet, router: router, onDismiss: router.dismiss) { destination in
			view(for: destination)
		}
		.fullScreen($isPresentingFullScreen, router: router) { destination in
			view(for:destination)
		}
		.onChange(of: router.presentingSheet) { oldValue, newValue in
			isPresentingSheet = newValue != .none
		}
		.onChange(of: router.presentingFullScreenCover) { oldValue, newValue in
			isPresentingFullScreen = newValue != .none
		}
		.environmentObject(router)
	}

	@ViewBuilder func view(for destination: Destination) -> some View {
		switch destination {
			case .mainMenu:
				LandingPage()
			case let .mockTest(testId):
				ExamView(examId: testId)
			case .resultsView(let result):
				ResultsView(result: result)
			case .handbook:
				HandbookMainMenu()
			case .handbookSearch(let queryString):
				HandbookMainMenu(queryString: queryString)
			case .handbookChapter(let index):
				let chp = menuViewModel.handbookViewModel.chapters[index]
				HandbookReader(chapter: chp, index: index)
			case .questionbank:
				QuestionBankView()
			case .monetization:
				MonitizationView()
			case .settings:
				SettingsView()
			case .progressReport:
				ProgressReport()
		}

	}
}

enum ViewState {
	case loading
	case content
	case error
}

