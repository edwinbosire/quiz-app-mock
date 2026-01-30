//
//  QuizUp_MockApp.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 29/10/2021.
//

import SwiftUI

@main
struct QuizUp_MockApp: App {
	@AppStorage("appearance") private var appearance: Appearance = .system

	@StateObject private var menuViewModel = MenuViewModel.shared
	@State var isShowingMonitizationPage = false
	@State private var path = NavigationPath()
	@Namespace var namespace
	@Environment(\.scenePhase) private var scenePhase
	var body: some Scene {
		WindowGroup {
			RouterView {
				LandingPage()
			}
				.environmentObject(menuViewModel)
				.preferredColorScheme(appearance.colorScheme)

		}
	}
}
