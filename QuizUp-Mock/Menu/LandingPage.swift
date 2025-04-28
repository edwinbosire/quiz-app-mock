//
//  MainMenu.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 15/03/2023.
//

import SwiftUI
import Charts

public let CornerRadius: CGFloat = 10.0
struct LandingPage: View {
	@EnvironmentObject private var menuViewModel: MenuViewModel
	@Namespace var namespace
	@Namespace var searchAnimation
	@State private var queryString = ""

	var body: some View {
		VStack(spacing: 0.0) {
			WelcomeBackHeaderView(isSearching: $menuViewModel.isSearching, animation: searchAnimation)
			HeaderSeparator()
			LandingPageContent()
		}
		// TODO: Implement search properly
//		.overlay {
//			SearchResultsView(viewModel: menuViewModel, animation: searchAnimation)
//				.opacity(menuViewModel.isSearching ? 1.0 : 0.0)
//				.animation(.smooth, value: menuViewModel.isSearching)
//		}
	}

	@State private var showSummary: Bool = false
	@State private var showHandbook: Bool = false
	@State private var showPracticeExamList: Bool = false

	@ViewBuilder func LandingPageContent() -> some View {
		ScrollView {
			VStack(spacing: 0.0) {
				SummaryView()
					.staggered(0.1)
				HandbookView(handbookViewModel: menuViewModel.handbookViewModel)
					.staggered(0.3)

				PracticeExamList()
					.staggered(0.4)
			}
		}
		.background(PastelTheme.background.gradient)
		.onAppear {
			withAnimation(.easeInOut.delay(0.1)) {
				showSummary = true
			}

			withAnimation(.easeInOut.delay(0.3)) {
				showHandbook = true
			}
			
			withAnimation(.easeInOut.delay(0.5)) {
				showPracticeExamList = true
			}
		}
		.onDisappear {
			showSummary = false
			showHandbook = false
			showPracticeExamList = false
		}
	}

	@ViewBuilder func HeaderSeparator() -> some View {
		Rectangle()
			.fill(PastelTheme.background.darken(by: 0.8))
			.frame(height: 1)

	}
}

struct MainMenu_Previews: PreviewProvider {
	struct ContentView: View {
		@Namespace var namespace
		@StateObject private var menuViewModel = MenuViewModel.shared
		var body: some View {
			NavigationStack {
				LandingPage()
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

extension View {
	func staggered(_ delay: Double = 0.1, repeats: Bool = false) -> some View {
		modifier(StaggeredAnimationModifier(delay: delay, repeats: repeats))
	}
}

struct StaggeredAnimationModifier: ViewModifier {
	@State private var offset: CGFloat = 20.0
	@State private var opacity: Double = 0.0
	@State private var shouldRepeatAnimation: Bool = true

	var delay: Double
	var repeats: Bool

	func body(content: Content) -> some View {
		content
			.offset(y: offset)
			.opacity(opacity)
			.onAppear {
				guard shouldRepeatAnimation else { return }
				withAnimation(.easeInOut(duration: 0.2).delay(delay)) {
					opacity = 1.0
				}

				withAnimation(.easeInOut(duration: 0.4).delay(delay)) {
					offset = 0.0
				}
				shouldRepeatAnimation = repeats

			}
			.onDisappear {
				guard shouldRepeatAnimation else { return }
				opacity = 0.0
				offset = 20.0

			}
	}
}
