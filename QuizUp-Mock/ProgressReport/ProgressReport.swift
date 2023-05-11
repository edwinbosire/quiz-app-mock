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
	@State var scale = 0.5
	var results: [ExamResult] {
		menuViewModel.results
	}

	var body: some View {
		NavigationStack {
			ProgressReportContainer(results: results)
			.scaleEffect(scale)
			.onAppear{
				withAnimation {
					scale = 1.0
				}
			}
			.navigationDestination(for: ExamResult.self) { result in
				ProgressReportDetailView(result: result)
			}
		}
		.task {
			await menuViewModel.reloadExams()
		}
	}
}

struct ProgressReportContainer: View {
	var results: [ExamResult]
	@State var scale = 0.5

	var body: some View {
		VStack(alignment: .center) {
			ProgressReportNavBar()
			if results.isEmpty {
				VStack {
					Text("No exam results available, complete at least one exam for the results to appear here.")
						.padding()

					FilledButton(title: "Start Exam", action: { print("start exam")})
						.frame(maxWidth: .infinity)

				}
			} else {


				List {
					BarCharts(results: results)
						.listRowBackground(Color.clear)
					ForEach(results) { result in
						NavigationLink(value: result) {
							ProgressReportRow(result: result)

						}
					}
					.listRowBackground(
						Rectangle()
							.fill(Color.rowBackground.opacity(0.5))
//							.background(.ultraThickMaterial)
					)

				}
				.listStyle(.plain)
			}
			Spacer()
		}
		.task {
//			await menuViewModel.reloadExams()
		}
		.gradientBackground()
	}
}

struct FilledButton: View {
	let title: String
	let action: () -> Void

	var body: some View {
		Button(title, action: action)
			.foregroundColor(.white)
			.padding()
			.background(Color.accentColor)
			.cornerRadius(8)
	}
}

struct ProgressReportNavBar: View {
	@Environment(\.dismiss) var dismiss
	var body: some View {
		ZStack {
			HStack {
				Text("Results")
					.font(.title)
			}
			.frame(maxWidth: .infinity, alignment: .center)

			HStack {
				Button { dismiss() } label: {
					Image(systemName: "xmark")
						.font(.title)
				}
				.padding()
			}
			.frame(maxWidth: .infinity, alignment: .trailing)

			Divider()
				.offset(y: 30.0)
		}
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

			ForEach(data, id: \.index) { result in
				BarMark(
					x: .value("exam", result.index),
					y: .value("Exam Score", result.score)
				)
			}
		}
		.foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
		.padding(.horizontal)
		.frame(height: 200, alignment: .center)
		.onAppear {
			data = results.enumerated().map { (index: $0, score: $1.scorePercentage)}
		}
	}
}
