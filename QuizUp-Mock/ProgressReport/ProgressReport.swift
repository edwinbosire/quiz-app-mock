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

	@State var scale = 0.5
	var startExamSelected: (() -> Void)?

	@State private var results = [ExamResult]()

	var body: some View {
		NavigationStack {
			if results.isEmpty {
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
							startExamSelected?()
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
				}
					.toolbar{
						ToolbarItem(placement: .navigationBarLeading) {
							Text("Results")
								.font(.title)
								.bold()
								.foregroundStyle(PastelTheme.title)
								.padding()
						}

						ToolbarItem(placement: .navigationBarTrailing) {
							HStack {
								Button { dismiss() } label: {
									Image(systemName: "xmark")
										.font(.title)
										.foregroundStyle(PastelTheme.orange.lighten)
								}
								.padding()
							}
						}
					}


			} else {
				ProgressReportContainer(results: results, startExamSelected: startExamSelected)
					.toolbar{
						ToolbarItem(placement: .navigationBarLeading) {
							Text("Results")
								.font(.title)
								.bold()
								.foregroundStyle(PastelTheme.title)
								.padding()
						}

						ToolbarItem(placement: .navigationBarTrailing) {
							HStack {
								Button { dismiss() } label: {
									Image(systemName: "xmark")
										.font(.title)
										.foregroundStyle(PastelTheme.orange.lighten)
								}
								.padding()
							}
						}
					}

			}
		}
		.task {
			results = await menuViewModel.reloadExams()
		}
		.scaleEffect(scale)
		.onAppear{
			withAnimation {
				scale = 1.0
			}
		}
		.background(PastelTheme.background.ignoresSafeArea())
	}
}

struct ProgressReportContainer: View {
	var results: [ExamResult]
	@State var scale = 0.5
	var startExamSelected: (() -> Void)?
	var body: some View {
		ScrollView {
			BarCharts(results: results.map { $0.scorePercentage})
				.padding()
//				.frame(minHeight: 300)

			VStack {
				ForEach(results) { result in
					NavigationLink(destination: ProgressReportDetailView(result: result)) {
						ProgressReportRow(result: result)
					}
				}
			}
			.frame(minHeight: 300)
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

struct ProgressReportRow: View {
	let result: ExamResult
	var body: some View {
		HStack {
			//			Image(systemName: "newspaper")

			VStack(alignment: .leading, spacing: 5.0) {
				Text("Practice Test \(result.examId)")
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

			Text(result.formattedScore)
				.font(.title2)
				.fontWeight(.semibold)
				.foregroundColor(PastelTheme.title)


			//			Image(systemName: "chevron.right")
			//				.font(.title)

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

struct ProgressReport_Previews: PreviewProvider {
	struct Preview: View {
		@StateObject private var menuViewModel = MenuViewModel.shared
		var body: some View {
			NavigationStack {
				ProgressReport()
					.environmentObject(menuViewModel)
			}
		}
	}
	static var previews: some View {
		Preview()
	}
}


struct ProgressReportDetailView: View {
	let result: ExamResult
	@State private var questions:[QuestionViewModel] = []
	var body: some View {
		ScrollView {
			ForEach(questions) { question in
				ResultsRow(viewModel: question)
					.padding()
			}
		}
		.onAppear {
			questions = result.questionsViewModels()
		}
	}
}

extension ExamResult {
	func questionsViewModels() -> [QuestionViewModel] {
		var viewModels = [QuestionViewModel]()

		for (i, question) in questions.enumerated() {
			let selectedAnswers = userSelectedAnswer[question.id] ?? []
			let vm = QuestionViewModel(question: question, selectedAnswers: selectedAnswers, index: i)
			viewModels.append(vm)
		}
		return viewModels
	}
}

struct BarCharts: View {
	let results: [Double]

	var body: some View {
		Chart {
			RuleMark(y: .value("Pass Mark", 75))
				.foregroundStyle(Color.pink.opacity(0.5))

			ForEach(Array(results.enumerated()), id: \.0) { ndx, result in
				BarMark(
					x: .value("Exam", String(ndx)),
					y: .value("Score", result)
				)
			}
		}
		.chartYAxisLabel("Score")
		.foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
		.frame(height: 200, alignment: .center)
	}
}

