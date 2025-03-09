//
//  ExamErrorScreen.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 09/03/2025.
//

import SwiftUI

struct ExamErrorScreen: View {
	@Environment(\.dismiss) var dismiss
	@State private var isRetrying = false
	@State private var scale = 0.5

	let retryAction: () async -> Void

	var body: some View {
		VStack {
			VStack {
				Text("We've encountered some problems starting the exam")
					.multilineTextAlignment(.center)
					.font(.title3)
					.fontWeight(.medium)
					.foregroundStyle(PastelTheme.title)
					.padding(.vertical)

				HStack {
					Button(action: retry) {
						HStack {
							Image(systemName: isRetrying ? "progress.indicator" : "arrow.clockwise")
							Text("Retry")
								.bold()
						}
						.foregroundStyle(PastelTheme.title)

					}
					.frame(height: 70)
					.frame(maxWidth: .infinity)
					.pastelThemeBackground(PastelTheme.green)

					Button(action: { dismiss() }) {
						HStack {
							Image(systemName: "arrowshape.turn.up.backward")

							Text("Exit")
								.bold()
						}
						.foregroundStyle(PastelTheme.title)
					}
					.frame(height: 70)
					.frame(maxWidth: .infinity)
					.pastelThemeBackground(PastelTheme.answerWrongBackground)

				}
				.padding(.horizontal)
				.transition(.opacity)

			}
			.padding()
			.background{
				RoundedRectangle(cornerRadius: CornerRadius)
					.fill(PastelTheme.background.lighten)
			}
			.overlay(alignment: .top) {
				Circle()
					.fill(PastelTheme.background.lighten)
					.overlay {
						Button(action: { dismiss() }) {

							Image(systemName: "xmark.circle.fill")
								.font(.largeTitle)
								.foregroundStyle(PastelTheme.answerWrongBackground.lighten)
						}
					}
					.alignmentGuide(.top){ $0[.top] + $0.height / 2}
					.frame(width: 55, height: 55)
			}
			.scaleEffect(scale)
			.onAppear { scale = 1.0 }
		}
		.padding(.horizontal)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(PastelTheme.background.gradient)

	}

	func retry() {
		Task {
			isRetrying = true
			await retryAction()
			isRetrying = false
		}
	}

}

#Preview {
	ExamErrorScreen(retryAction: {
		print("Async retry action called")
	})
}
