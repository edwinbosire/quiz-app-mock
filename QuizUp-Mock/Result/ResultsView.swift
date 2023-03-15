//
//  ResultsView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 13/03/2023.
//

import SwiftUI

struct ResultsView: View {
	@ObservedObject var viewModel: ExamViewModel
	@State private var ringProgress = 0.0

	var background: some View {
		RadialGradient(gradient: Gradient(colors: [.yellow.opacity(0.3), .black.opacity(0.5)]), center: UnitPoint(x: 0.5, y: 0.8), startRadius: 0, endRadius: 650)
	}
	var body: some View {
		ZStack {
			Color.yellow.opacity(0.01)
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
				Circle()
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
			background
				.ignoresSafeArea()
				.padding(.top, -450)
			VStack {
				HStack {
					Spacer()

					Button {
						viewModel.restartExam()
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

				CircularProgressView(progress: $ringProgress
									 ,primaryColor: .pink)
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
		ResultsView(viewModel: examViewModel)
	}
}
