//
//  ProgressReport.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI
import Charts

struct ProgressReport: View {
	@EnvironmentObject private var menuViewModel: MenuViewModel
	@Environment(\.dismiss) var dismiss
	@Environment(Router.self) var router

	@State var scale = 1.0
	var startExamSelected: (() -> Void)?

	@State private var results = [ExamResultViewModel]()
	@State private var viewState: ViewState = .loading

	var body: some View {
		NavigationStack {
			VStack(spacing: 0.0) {
				navigationBar()
				switch viewState {
					case .loading:
						ProgressReportLoadingView()
							.transition(.move(edge: .bottom))
					case .content:
						ProgressReportContainer(results: results) {
							router.navigate(to: .mockTest(0), navigationType: .fullScreenCover)
						}
						.transition(.opacity)
					case .empty:
						NoProgressReportView {
							dismiss()
							router.navigate(to: .mockTest(0), navigationType: .fullScreenCover)
						}
					case .error:
						ProgressReportErrorView()
				}
			}
		}
		.navigationBarHidden(true)
		.navigationBarBackButtonHidden(true)
		.toolbar {
			toolBarBackButton()
		}
		.task { await reload() }
		.scaleEffect(scale)
		.animation(.easeInOut, value: scale)
		.onAppear{ scale = 1.0 }
//		.background(PastelTheme.background.ignoresSafeArea())

	}

	func navigationBar() -> some View {
		Rectangle()
			.fill(PastelTheme.navBackground)
			.frame(maxWidth: .infinity)
			.frame(height: 60)
			.overlay(alignment: .topLeading) {
				Button {
					router.dismiss()
				} label: {
					HStack {
						Image(systemName: "chevron.backward")
							.rotationEffect(.degrees(-90))
						Text("Exam Reports")
					}
					.bold()
					.foregroundStyle(PastelTheme.title)
				}
				.padding()
			}
	}

	@ToolbarContentBuilder
	func toolBarBackButton() -> some ToolbarContent {
		ToolbarItem(placement: .navigationBarLeading) {
			Button {
				router.dismiss()
			} label: {
				HStack {
					Image(systemName: "chevron.backward")
					Text("Back")
				}
				.bold()
				.foregroundStyle(PastelTheme.title)
			}
		}
	}

	func reload() async {
		viewState = .loading
		await menuViewModel.loadResults()
		results = menuViewModel.results
		viewState = results.isEmpty ? .empty : .content
	}
}

struct ProgressReportContainer: View {
	var results: [ExamResultViewModel]
	@State var scale = 0.5
	var startExamSelected: (() -> Void)?
	@Environment(Router.self) var router

	var body: some View {
		ScrollView {
			if results.count > 1 {
				BarCharts(results: results)
					.staggered(0.1)
					.background(Color.white)
					.zIndex(.infinity)
			}
			VStack {
				ForEach(results.indices, id: \.self) { index in
					let result = self.results[index]
					NavigationLink(destination: ProgressReportDetailView(result: result)) {
						ProgressReportRow(result: result, index: index)
							.staggered(0.15*CGFloat(index))
					}
				}
			}
			.padding()
		}
		.background(PastelTheme.background)
	}
}

struct FilledButton: View {
	let title: String
	let action: () -> Void

	var body: some View {
		Button(title, action: action)
			.buttonStyle(.bordered)
			.foregroundColor(.white)
			.tint(Color.purple)
			.buttonBorderShape(.capsule)
	}
}

struct NoProgressReportView: View {
	var startExam: (() -> Void)?
	@Environment(\.dismiss) var dismiss

	var body: some View {
		ZStack {
			PastelTheme.background.ignoresSafeArea()
			VStack {
				Text("No exam results available, complete at least one exam for the results to appear here.")
					.multilineTextAlignment(.center)
					.font(.title)
					.frame(maxWidth: .infinity, alignment: .center)
					.foregroundStyle(PastelTheme.title)
					.padding(.vertical)

				Button(action: {
					startExam?()
				}) {
					VStack {
						Text("Start Exam")
							.font(.headline)
							.fontWeight(.bold)
							.foregroundStyle(PastelTheme.title)
					}
					.frame(maxWidth: .infinity)
					.frame(height: 50.0)
					.background {
						RoundedRectangle(cornerRadius: CornerRadius)
							.fill(Color.pink.darken)
							.shadow(color: .black.opacity(0.09), radius: 4, y: 2)
							.overlay {
								RoundedRectangle(cornerRadius: CornerRadius)
									.fill(Color.pink.lighten)
									.offset(y: -4.0)
							}
					}
					.clipShape(RoundedRectangle(cornerRadius: CornerRadius))

				}
			}
			.padding(.horizontal)
			.transition(.move(edge: .bottom))
		}
	}
}

struct ProgressReportRow: View {
	let result: ExamResultViewModel
	let index: Int
	var body: some View {
		HStack {
			VStack(alignment: .leading, spacing: 5.0) {
				Text("Practice Test \(index)")
					.font(.title3)
					.fontWeight(.semibold)
					.foregroundStyle(PastelTheme.title)

				HStack {
					Group {
						Image(systemName: "checkmark.circle")
						Text("\(result.correctQuestions.count) correct")
							.foregroundStyle(PastelTheme.subTitle)

					}
					.font(.caption)
					.foregroundStyle(PastelTheme.answerCorrectBackground)

					Group {
						Image(systemName: "xmark.circle")
						Text("\(result.incorrectQuestions.count) wrong")
							.foregroundStyle(PastelTheme.subTitle)
					}
					.font(.caption)
					.foregroundColor(PastelTheme.answerWrongBackground)
				}

				Text(result.formattedDate)
					.font(.footnote)
					.fontWeight(.semibold)
					.foregroundColor(PastelTheme.subTitle)
			}

			Spacer()

			Text(result.formattedPercentageScore)
				.font(.title2)
				.fontWeight(.semibold)
				.foregroundColor(PastelTheme.title)

		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: CornerRadius)
				.fill(PastelTheme.rowBackground.darken)
				.shadow(color: .black.opacity(0.09), radius: 4, y: 2)
				.overlay {
					RoundedRectangle(cornerRadius: CornerRadius)
						.fill(PastelTheme.rowBackground.lighten(by: 0.1))
						.offset(y: -4.0)
				}
		)
		.clipShape(RoundedRectangle(cornerRadius: CornerRadius, style: .continuous))
	}
}

struct ProgressReportLoadingView: View {
	var body: some View {
		VStack {
			ProgressView {
				Text("Loading Reports...")
					.font(.headline)
					.foregroundStyle(PastelTheme.title)
			}
			.tint(PastelTheme.title)

		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(PastelTheme.background.gradient)
	}
}

struct ProgressReportErrorView: View {
	@Environment(\.dismiss) var dismiss

	var body: some View {
		ExamErrorScreen(retryAction: {
			print("Async retry action called")
			dismiss()
		})
	}
}

#Preview{
	@Previewable @StateObject var menuViewModel = MenuViewModel.shared
	RouterView {
//		NavigationStack {
			ProgressReport()
				.environmentObject(menuViewModel)
//		}
	}
}

