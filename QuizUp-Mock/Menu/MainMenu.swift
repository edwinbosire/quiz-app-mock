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
//				Color("Background")
//					.opacity(0.9)
////					.background(.thinMaterial)
//					.ignoresSafeArea()

				ScrollView {
					VStack {
						SummaryView(route: $route)
						HandbookView(route: $route)
						PracticeExamList()
					}
				}
				WelcomeBackHeaderView()
			}
			.background(Backgrounds())
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
	let color: [Color] = [.blue, .purple, .blue, .cyan, .indigo, .mint, .purple, .teal, .green, .blue]

	var body: some View {
		ZStack {
			ForEach(color, id: \.self) { color in
				BackgroundBlob(color: color)
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
