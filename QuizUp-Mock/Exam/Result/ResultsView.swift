//
//  ResultsView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 13/03/2023.
//

import SwiftUI

struct ResultsView: View {
	let result: ExamResult
	var body: some View {
		ResultsViewContainer(result: result)
	}
}

struct ResultsViewContainer: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

	let result: ExamResult
	@State private var ringProgress = 0.0

	var body: some View {
		ZStack {
			background()
			ScrollView {
				VStack {
					resultsHeader()
					ForEach(result.questions) { question in
						let vm = QuestionViewModel(question: question)
						ResultsRow(question: vm)
							.padding()
					}
					Spacer()
				}
				.onAppear {
					ringProgress = result.score
				}
			}

			confetti()
		}
	}

	private func background() -> some View {
		LinearGradient(colors: [Color.blue.opacity(0.5), Color.defaultBackground,Color.defaultBackground, Color.blue.opacity(0.5)], startPoint: .top, endPoint: .bottom)
			.blur(radius: 75)
			.ignoresSafeArea()
	}

	private func confetti() -> some View {
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
//						_ = viewModel.restartExam()
						presentationMode.wrappedValue.dismiss()
					} label: {
						Image(systemName: "xmark")
							.font(.title)
							.bold()
							.foregroundStyle(.secondary)
					}
					.padding()

				}
				Text("Congratulations on completing your exam")
					.font(.title3)

				CircularProgressView(progress: $ringProgress, score:
										"\(result.correctQuestions.count) / \(result.questions.count)",primaryColor: .pink)
					.frame(width: 200)
					.padding()
				Spacer()

				Text(String(format: " You've scored: %.0f%%", min(max(result.scorePercentage, 0.0), 100)))
					.font(.headline)
					.foregroundStyle(.primary)
				Text(result.prompt)
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
			.padding(.bottom)
		}
	}
}

struct ResultsRow: View {
	let question: QuestionViewModel
	var body: some View {
		VStack(alignment: .leading) {
			Text("\(question.index + 1). \(question.title)")
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

				}
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

}
struct ResultsView_Previews: PreviewProvider {
	static var previews: some View {
		let exam = Exam.mock()
		let result = ExamResult(exam: exam)
		ResultsView(result: result)
	}
}
