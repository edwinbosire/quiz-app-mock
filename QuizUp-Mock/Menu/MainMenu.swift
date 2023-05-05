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
	@Namespace var searchAnimation

	@Environment(\.colorScheme) var colorScheme
	var isDarkMode: Bool { colorScheme == .dark }
	@State private var queryString = ""

	var body: some View {
		NavigationStack {
			ZStack(alignment: .topLeading) {
				ScrollView {
					VStack(spacing: 10.0) {
						SummaryView()
						HandbookView(handbookViewModel: menuViewModel.handbookViewModel)
						PracticeExamList()
					}
				}
				WelcomeBackHeaderView(isSearching: $menuViewModel.isSearching, animation: searchAnimation)

//				if menuViewModel.isSearching {
//					SearchResultsView(queryString: $menuViewModel.searchQuery, isSearching: $menuViewModel.isSearching, animation: namespace)
//				}

			}
			.background(Backgrounds())
		}
		.overlay(
			ZStack {
				if menuViewModel.isSearching {
					SearchResultsView(queryString: $menuViewModel.searchQuery, isSearching: $menuViewModel.isSearching, animation: searchAnimation)
				}
			}
		)
		.onAppear {
			Task {
				await menuViewModel.reloadExams()
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

struct Backgrounds: View {
	let color: [Color] = [.blue, .purple, .cyan, .indigo, .mint, .purple, .teal, .green]

	var body: some View {
		ZStack {
			ForEach(0..<15) { _ in
				BackgroundBlob(color: color.randomElement()!)
			}
		}
		.background(Color("Background").opacity(0.9))
	}
}

struct BackgroundBlob: View {
	@State private var rotationAmount = 0.0
	private let screen = UIScreen.main.bounds
	let alignment: Alignment = [.topLeading, .topTrailing, .bottomLeading, .bottomTrailing].randomElement()!
	var color: Color
	var body: some View {
		Ellipse()
			.fill(color)
			.frame(width: .random(in: 200...500), height: .random(in: 200...500))
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
			.offset(x: .random(in: 0...screen.width), y: .random(in: 0...screen.height))
			.rotationEffect(.degrees(rotationAmount))
			.animation(.linear(duration: .random(in: 60...80)).repeatForever(), value: rotationAmount)
			.onAppear {
				rotationAmount = .random(in: -360...360)
			}
			.blur(radius: 75)

	}
}
