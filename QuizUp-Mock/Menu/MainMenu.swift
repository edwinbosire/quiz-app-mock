//
//  MainMenu.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 15/03/2023.
//

import SwiftUI

struct MainMenu: View {
	@EnvironmentObject private var menuViewModel: MenuViewModel
	@Binding var route: Route
	var namespace: Namespace.ID

	@Environment(\.colorScheme) var colorScheme
	var isDarkMode: Bool { colorScheme == .dark }

	var body: some View {
		NavigationStack {
			ZStack(alignment: .topLeading) {
				Color("Background")
					.opacity(0.9)
					.ignoresSafeArea()

				ScrollView {
					VStack {
						SummaryView(route: $route)
						HandbookView(route: $route)
						PracticeExamList()
					}
				}
				WelcomeBackHeaderView()
			}
		}
	}
}

struct MainMenu_Previews: PreviewProvider {
	struct ContentView: View {
		@Namespace var namespace
		@StateObject private var menuViewModel = MenuViewModel.shared
		var body: some View {
			NavigationStack {
				MainMenu(route: .constant(.mainMenu), namespace: namespace)
			}
			.environmentObject(menuViewModel)
		}
	}

	static var previews: some View {
		ContentView()
    }
}

