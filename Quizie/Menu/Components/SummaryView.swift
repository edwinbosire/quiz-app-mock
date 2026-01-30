//
//  SummaryView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 15/04/2023.
//

import SwiftUI
import Observation

struct SummaryView: View {
	@Environment(\.featureFlags) var featureFlags
	@Environment(\.colorScheme) var colorScheme
	@EnvironmentObject private var menuViewModel: MenuViewModel
	@Environment(Router.self) var router

	var isDarkMode: Bool { colorScheme == .dark }

	@State private var averageScore = 0.0
	@State private var readingProgress = 0.0
	@State private var showHandbook = false

	var body: some View {
		HStack {
			ProgressReportButton()
			Spacer().frame(width: 20)
			HandbookButton()
		}
		.padding()
		.padding(.top)
		.clipShape(RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 20))
		.shadow(color: .black.opacity(0.09), radius: 4, x:0.0, y: 2)
		.task {
			try? await Task.sleep(nanoseconds: UInt64(3e+9))
			averageScore = 75.5
			readingProgress = menuViewModel.handbookViewModel.totalProgress
		}
	}

	@ViewBuilder
	func ProgressReportButton() -> some View {
		Button(action: {
			router.navigate(to: .progressReport, navigationType: .sheet)
		}) {
			CountingText(value: averageScore, subtitle: "Average Score")
				.animation(.easeInOut(duration: 0.5), value: averageScore)
				.frame(maxWidth: .infinity)
				.frame(height: 150)

		}
		.buttonStyle(RaisedButtonStyle(color: Color.pink))
	}

	@ViewBuilder
	func HandbookButton() -> some View {
		Button(action: {
			router.navigate(to: .handbook)
		}){
			CountingText(value: readingProgress, subtitle: "Total Progress")
				.animation(.easeInOut(duration: 0.5), value: readingProgress)
				.frame(maxWidth: .infinity)
				.frame(height: 150)
		}
		.buttonStyle(RaisedButtonStyle(color: Color.teal))

	}
}

struct RaisedButtonStyle: ButtonStyle {
	let color: Color

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.offset(y: configuration.isPressed ? 4.0 : 0.0)
			.background(
				ZStack {
					RoundedRectangle(cornerRadius: CornerRadius)
						.fill(color.darken)
						.offset(y: 4)

					RoundedRectangle(cornerRadius: CornerRadius)
						.fill(color.lighten)
						.offset(y: configuration.isPressed ? 4.0 : 0.0)
				}
			)
			.foregroundStyle(PastelTheme.title)
	}
}

struct CountingText: View, Animatable {
	var value: Double
	var subtitle: String
	var fractionLength = 1

	var animatableData: Double {
		get { value }
		set { value = newValue }
	}

	var body: some View {
		VStack {
			Text("\(value.formatted(.number.precision(.fractionLength(fractionLength))))%")
				.font(.largeTitle)
				.bold()
				.foregroundStyle(.primary)
			//				.foregroundColor(Color.titleText)
				.foregroundColor(.white)
			Text(subtitle)
				.font(.title3)
				.foregroundStyle(.secondary)
			//				.foregroundColor(Color.titleText)
				.foregroundColor(.white)


		}
	}
}

#if DEBUG
#Preview {
	@Previewable @State var router = MockRouter()

	SummaryView()
		.background(PastelTheme.background.ignoresSafeArea())
		.environmentObject(MenuViewModel.shared)
		.environment(router)
}

@Observable
final class MockRouter {
	func navigate(to destination: Destination, navigationType: NavigationType = .push) {
	}
}
#endif
