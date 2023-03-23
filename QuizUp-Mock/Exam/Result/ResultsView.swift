//
//  ResultsView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 13/03/2023.
//

import SwiftUI

struct ResultsView: View {
	@ObservedObject var viewModel: ExamViewModel
	@Binding var route: Route
	var body: some View {
		ResultsViewContainer(viewModel: viewModel, route: $route)
	}
}

struct ResultsViewContainer: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

	@ObservedObject var viewModel: ExamViewModel
	@Binding var route: Route
	@State private var ringProgress = 0.0

	var body: some View {
		ZStack {
			Color("Background")
				.opacity(0.8)
				.ignoresSafeArea()
			ScrollView {
				VStack {
					resultsHeader()
					ForEach(Array(viewModel.availableQuestions.enumerated()), id: \.offset) { index, question in
						ResultsRow(index, question)
							.padding()
					}
					Spacer()
				}
				.onAppear {
					ringProgress = viewModel.scorePercentage / 100
				}
			}

			ZStack {
				Rectangle()
					.fill(Color.blue)
					.frame(width: 12, height: 12)
					.modifier(ParticlesModifier())
					.offset(x: 0.0, y : -250)

				Circle()
					.fill(Color.green)
					.frame(width: 12, height: 12)
					.modifier(ParticlesModifier())
					.offset(x: -60, y : -200)

				Circle()
					.fill(Color.red)
					.frame(width: 12, height: 12)
					.modifier(ParticlesModifier())
					.offset(x: 160, y : -200)
			}

		}
	}

	func icon(for question: QuestionViewModel, answer: Answer) -> some View {
		if question.selectedAnswers.contains(answer) {
			return Image(systemName: question.answerState[answer] == .correct ? "xmark.circle" : "checkmark.circle")
				.foregroundColor(question.answerState[answer] == .correct ? .green : .pink)
		} else if answer.isAnswer {
			return Image(systemName: "checkmark.circle")
				.foregroundColor(.green)

		}else {
			return Image(systemName:"circle.dotted")
				.foregroundColor(.gray)

		}
	}

	fileprivate func resultsHeader() -> some View {
		return ZStack {
			Color("Background")
				.ignoresSafeArea()
				.padding(.top, -450)
				.offset(y: -100)

			Color("Background")
				.clipShape(RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 50))
				.shadow(color: .black.opacity(0.1), radius: 10, x:0.0, y: 15.0)


			VStack {
				HStack {
					Spacer()

					Button {
						viewModel.restartExam()
						presentationMode.wrappedValue.dismiss()
					} label: {
						Image(systemName: "xmark")
							.font(.title)
							.bold()
							.foregroundStyle(.secondary)
					}
					.padding()

				}
				//			Spacer()
				Text("Congratulations on completing your exam")
					.font(.title3)

				CircularProgressView(progress: $ringProgress, score:
										"\(viewModel.score) / \(viewModel.availableQuestions.count)",primaryColor: .pink)
					.frame(width: 200)
					.padding()
				Spacer()

				Text(String(format: " You've scored: %.0f%%", min(max(viewModel.scorePercentage, 0.0), 100)))
					.font(.headline)
					.foregroundStyle(.primary)
				Text(viewModel.prompt)
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
			.padding(.bottom)
		}
	}

	fileprivate func ResultsRow(_ index: Int, _ question: QuestionViewModel) -> some View {
		return VStack(alignment: .leading) {
			Text("\(index + 1). \(question.title)")
				.font(.headline)
				.foregroundStyle(.primary)
				.padding(.bottom, 3)

			VStack(alignment: .leading) {
				ForEach(question.options, id: \.self) { answer in
					VStack {
						HStack {
							icon(for: question, answer: answer)

							Text(answer.title)
								.foregroundStyle(.secondary)


							Spacer()
						}
						.background(RoundedRectangle(cornerRadius: 8)
							.fill(.gray.opacity(0.2))
							.opacity(question.selectedAnswers.contains(answer) ? 1 : 0))

						Spacer()
							.frame(height: 1)
					}
					//							.padding(.vertical, 1)

				}
			}
		}
	}
}


struct ResultsView_Previews: PreviewProvider {
	static var previews: some View {
		let examViewModel = ExamViewModel.mock()
		ResultsView(viewModel: examViewModel, route: .constant(.mockTest(testId: 0)))
	}
}
