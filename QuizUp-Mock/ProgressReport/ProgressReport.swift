//
//  ProgressReport.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct ProgressReport: View {
	@EnvironmentObject private var menuViewModel: MenuViewModel
	@Binding var route: Route
	@State var scale = 0.5

	var body: some View {
		NavigationStack {
			ProgressReportContainer(menuViewModel: menuViewModel, route: $route)
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
	@Binding var route: Route
	@State var scale = 0.5

	var body: some View {
		VStack(alignment: .center) {
			ProgressReportNavBar(route: $route)
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
	@Binding var route: Route
	var body: some View {
		ZStack {
			HStack {
				Text("Results")
					.font(.title)
			}
			.frame(maxWidth: .infinity, alignment: .center)

			HStack {
				Button {route = .mainMenu} label: {
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
//							Text("\(exam.questions.count) Questions")
//								.font(.subheadline)
//								.foregroundStyle(.secondary)

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
	}
}
struct ProgressReport_Previews: PreviewProvider {
	struct Preview: View {
		@StateObject private var menuViewModel = MenuViewModel.shared
		var body: some View {
			NavigationStack {
				ProgressReport(route: .constant(.progressReport))
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
	}
}
