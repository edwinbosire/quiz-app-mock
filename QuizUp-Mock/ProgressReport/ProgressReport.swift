//
//  ProgressReport.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct ProgressReport: View {
	@EnvironmentObject private var menuViewModel: MenuViewModel
	@State var scale = 0.5

	var body: some View {
		NavigationStack {
			ProgressReportContainer(menuViewModel: menuViewModel)
			.scaleEffect(scale)
			.onAppear{
				withAnimation {
					scale = 1.0
				}
			}
			.navigationDestination(for: ExamViewModel.self) { exam in
				ProgressReportDetailView(exam: exam)
			}

		}
	}
}

struct ProgressReportContainer: View {
	var menuViewModel: MenuViewModel
	@State var scale = 0.5

	var body: some View {
		VStack(alignment: .center) {
			ProgressReportNavBar()
			if menuViewModel.completedExams.isEmpty {
				VStack {
					Text("No exam results available, complete at least one exam for the results to appear here.")
						.padding()

					FilledButton(title: "Start Exam", action: {print("start exam")})
						.frame(maxWidth: .infinity)

				}
			} else {
				ForEach(menuViewModel.completedExams) { exam in
					NavigationLink(value: exam) {
						ProgressReportRow(exam: exam)
					}
				}
			}
			Spacer()
		}
		.task {
			await menuViewModel.reloadExams()
		}
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
	let exam: ExamViewModel
	var body: some View {
		VStack(alignment: .leading) {
			HStack(alignment: .center) {
				Image(systemName: "newspaper")

				VStack(alignment: .leading) {
					Text("Practice Test \(exam.id)")
						.font(.title3)
						.foregroundStyle(.primary)

					HStack {
						Group {
							Image(systemName: "xmark.seal")
							Text("\(exam.exam.incorrectQuestions.count) wrong")
						}
						.font(.caption)
						.foregroundColor(.red)



						Group {
							Image(systemName: "checkmark.seal")
							Text("\(exam.exam.correctQuestions.count) correct")
						}
						.font(.caption)
						.foregroundColor(.green)
					}
					.foregroundStyle(.tertiary)

				}

				Spacer()

				Text(exam.formattedScore)
					.font(.title)

				Image(systemName: "chevron.right")
					.font(.title)

			}
			.padding(.horizontal)

			Divider()
				.padding(.leading)
		}
		.background(
			LinearGradient(colors: [Color.blue.opacity(0.5), Color.defaultBackground,Color.defaultBackground, Color.blue.opacity(0.5)], startPoint: .top, endPoint: .bottom)
				.blur(radius: 75)
		)
	}
}

struct ProgressReport_Previews: PreviewProvider {
	struct Preview: View {
		@StateObject private var menuViewModel = MenuViewModel.shared
		var body: some View {
			NavigationStack {
				ProgressReport()
			}
			.environmentObject(menuViewModel)
		}
	}
	static var previews: some View {
		Preview()
	}
}


struct ProgressReportDetailView: View {
	let exam: ExamViewModel
	var body: some View {
		ScrollView {
			ForEach(exam.questions, id: \.id) { question in
				ResultsRow(question: question)
					.padding()
			}
		}
		.background(
			LinearGradient(colors: [Color.blue.opacity(0.5), Color.defaultBackground,Color.defaultBackground, Color.blue.opacity(0.5)], startPoint: .top, endPoint: .bottom)
				.blur(radius: 75)
		)
	}
}
