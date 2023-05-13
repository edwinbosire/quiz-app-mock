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
		NavigationView {

			ProgressReportContainer(results: results, startExamSelected: startExamSelected)
				.scaleEffect(scale)
				.onAppear{
					withAnimation {
						scale = 1.0
					}
				}
				.task {
					await menuViewModel.reloadExams()
				}
				.toolbar{
					ToolbarItem(placement: .navigationBarLeading) {
						Text("Results")
							.font(.title)
							.bold()
							.padding()
					}

					ToolbarItem(placement: .navigationBarTrailing) {
						HStack {
							Button { dismiss() } label: {
								Image(systemName: "xmark")
									.font(.subheadline)
							}
							.padding()
						}

					}
				}
				.gradientBackground()
				.onAppear {
					Task {
						results = menuViewModel.results
					}
				}
		}
	}
}

struct ProgressReportContainer: View {
	var results: [ExamResult]
	@State var scale = 0.5
	var startExamSelected: (() -> Void)?
	var body: some View {
		VStack {
			BarCharts(results: results)
				.padding()

			List {
				Section {
					ForEach(results) { result in
						NavigationLink(destination: ProgressReportDetailView(result: result)) {
							ProgressReportRow(result: result)
						}
					}
					.listRowBackground(
						Rectangle()
							.fill(Color.rowBackground.opacity(0.5))
					)

				} header: {
					//					BarCharts(results: results)
					//						.padding()
					//						.listRowBackground(Color.clear)

				}

			}
			.listStyle(.plain)
			.overlay {
				if results.isEmpty {
					VStack {
						Text("No exam results available, complete at least one exam for the results to appear here.")
							.padding()

						FilledButton(title: "Start Exam", action: { startExamSelected?() })

					}
				}
			}
		}
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
					.foregroundColor(.titleText)
					.font(.title3)
					.foregroundStyle(.primary)

				HStack {
					Group {
						Image(systemName: "checkmark.circle")
						Text("\(result.correctQuestions.count) correct")
					}
					.font(.caption)
					.foregroundColor(.green)

					Group {
						Image(systemName: "xmark.circle")
						Text("\(result.incorrectQuestions.count) wrong")
					}
					.font(.caption)
					.foregroundColor(.red)
				}
				.foregroundStyle(.tertiary)

				Text(result.formattedDate)
					.font(.footnote)
					.foregroundStyle(.tertiary)
					.foregroundColor(.subTitleText)
			}

			Spacer()

			Text(result.formattedScore)
				.font(.title2)
				.foregroundColor(.titleText)


//			Image(systemName: "chevron.right")
//				.font(.title)

		}
		.padding(.horizontal)
	}
}

struct ProgressReport_Previews: PreviewProvider {
	struct Preview: View {
		var body: some View {
			NavigationStack {
				ProgressReport()
			}
		}
	}
	static var previews: some View {
		Preview()
	}
}


struct ProgressReportDetailView: View {
	let result: ExamResult
	var body: some View {
		ScrollView {
			ForEach(result.questions) { question in
				let vm = QuestionViewModel(question: question)
				ResultsRow(question: vm)
					.padding()
			}
		}
		.gradientBackground()
	}
}

struct BarCharts: View {
	let results: [ExamResult]


	@State private var data: [(index: Int, score: Double)] = []

	var body: some View {
		Chart {
			RuleMark(y: .value("Pass Mark", 75))
				.foregroundStyle(Color.pink.opacity(0.5))

			ForEach(Array(results.enumerated()), id: \.offset) { ndx, result in
				BarMark(
					x: .value("exam", result.chartDate),
					y: .value("Exam Score", result.scorePercentage)
				)
			}
		}
		.chartYAxisLabel("Score")
		.foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
		.frame(height: 200, alignment: .center)
		.onAppear {
			Task {
				data = results.enumerated().map { (index: $0, score: $1.scorePercentage)}
			}
		}
	}
}

