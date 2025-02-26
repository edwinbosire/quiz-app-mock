//
//  SummaryView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 15/04/2023.
//

import SwiftUI

struct SummaryView: View {
	@Environment(\.featureFlags) var featureFlags
	@Environment(\.colorScheme) var colorScheme
	@EnvironmentObject private var menuViewModel: MenuViewModel
	@EnvironmentObject var router: Router

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
//		.background(.ultraThinMaterial)
		.clipShape(RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 20))
		.shadow(color: .black.opacity(0.09), radius: 4, x:0.0, y: 2)
		.onAppear {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				averageScore = 75.5
				readingProgress = menuViewModel.handbookViewModel.totalProgress
			}
		}
	}

	@ViewBuilder
	func ProgressReportButton() -> some View {
		Button(action: {
			router.navigate(to: .progressReport, navigationType: .fullScreenCover)
		}) {
			VStack {
				CountingText(value: averageScore, subtitle: "Average Score")
					.animation(.easeInOut(duration: 0.5), value: averageScore)
			}
			.frame(maxWidth: .infinity)
			.frame(height: 150)
			.background {
				RoundedRectangle(cornerRadius: 10)
					.fill(Color.pink)
					.shadow(color: .black.opacity(0.09), radius: 4, y: 2)
			}
		}
	}

	@ViewBuilder
	func HandbookButton() -> some View {
		Button(action: {
			router.navigate(to: .handbook)
		}){
			VStack {
				CountingText(value: readingProgress, subtitle: "Total Progress")
					.animation(.easeInOut(duration: 0.5), value: readingProgress)

			}
			.frame(maxWidth: .infinity)
			.frame(height: 150)
			.background {
				RoundedRectangle(cornerRadius: 10)
					.fill(.teal)
					.shadow(color: .black.opacity(0.09), radius: 4, y: 2)
			}
		}

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

struct SummaryView_Previews: PreviewProvider {
	static var previews: some View {
		@State var route = NavigationPath()
		SummaryView()
			.background(Backgrounds())
	}
}
