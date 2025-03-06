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
	@EnvironmentObject var router: Router
	@State private var ringProgress = 0.0

	var score: String {
		"\(result.correctQuestions.count) / \(result.questions.count)"
	}

	var body: some View {
		VStack {
			ScrollView {
				VStack (spacing: 10.0) {
					ResultsHeader()
						.padding(.bottom)
					ForEach(Array(result.questions.enumerated()), id: \.offset) { index, question in
						let vm = QuestionViewModel(question: question, index: index)
						ResultsRow(question: vm)
					}
					Spacer()

				}
				.onAppear {
					ringProgress = result.score
				}
			}

//			HStack {
//				TryAgainButton()
//				NextQuizButton()
//			}
//			.padding(.horizontal)


		}
		.overlay(confetti())
		.background(PastelTheme.background)
	}

	@ViewBuilder func TryAgainButton() -> some View {
		Button {
			router.navigate(to: .mockTest( result.examId))
		} label: {
			VStack {
				Text("Try Again")
					.font(.title)
					.foregroundStyle(.primary)
					.padding()

			}
			.frame(maxWidth: .infinity)
			.background(					RoundedRectangle(cornerRadius: CornerRadius)
				.fill(Color("Background"))
				.shadow(color: .black.opacity(0.09), radius: 4, y: 2)
			)

		}
	}

	@ViewBuilder func NextQuizButton() -> some View {
		Button {
			router.navigate(to: .mockTest( result.examId + 1))
		} label: {
			VStack {
				Text("Next Quiz")
					.font(.title)
					.foregroundStyle(.primary)
					.foregroundStyle(.cyan)
					.padding()

			}
			.frame(maxWidth: .infinity)
			.background(					RoundedRectangle(cornerRadius: CornerRadius)
				.fill(Color("Background"))
				.shadow(color: .black.opacity(0.09), radius: 4, y: 2)
			)

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

	@ViewBuilder func ResultsHeader() -> some View {
		VStack(alignment: .center, spacing: 10.0) {
			HStack {
				Spacer()
				Text("Report Card")
					.font(.title)
					.fontWeight(.semibold)
					.foregroundStyle(PastelTheme.title)

				Spacer()

				Button {
					presentationMode.wrappedValue.dismiss()
					router.popToRoot()
				} label: {
					Image(systemName: "xmark")
						.font(.title)
						.fontWeight(.medium)
						.foregroundStyle(PastelTheme.orange)
				}
			}
			.padding(.bottom)

			HStack {

				CircularProgressView(progress: $ringProgress, primaryColor: PastelTheme.deepOrange)
					.frame(width: 150)
					.overlay {
						VStack {
							Text(String(format: "%.0f%%", min(ringProgress, 1.0)*100.0))
								.font(.largeTitle)
								.monospacedDigit()
								.bold()
								.foregroundStyle(PastelTheme.title)

							Text(score)
								.font(.caption)
								.foregroundStyle(.secondary)
						}

					}

				Spacer()
				VStack(alignment: .trailing) {
					Text("You're score")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundStyle(PastelTheme.title)
					Text(String(format: "%0.1f %%",result.scorePercentage))
						.font(.subheadline)
						.foregroundStyle(.secondary)
						.padding(.bottom, 8.0)

					Text("Wrong Answers")
						.font(.headline)
						.foregroundStyle(PastelTheme.title)
					Text("\(result.correctQuestions.count)")
						.font(.subheadline)
						.foregroundStyle(.secondary)
						.padding(.bottom, 8.0)

					Text("Minimum to pass")
						.font(.headline)
						.fontWeight(.bold)
						.foregroundStyle(PastelTheme.title)
					Text("18/24")
						.font(.subheadline)
						.foregroundStyle(.secondary)
						.padding(.bottom, 8.0)

					Spacer()

				}
			}
			.padding()

			Text(result.prompt)
				.font(.title3)
				.fontWeight(.bold)
				.foregroundStyle(PastelTheme.title)
				.multilineTextAlignment(.center)
				.padding([.horizontal, .bottom])

		}
		.padding()
		.background(
			PastelTheme.navBackground
				.ignoresSafeArea()
				.clipShape(RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 50))
				.shadow(color: .black.opacity(0.1), radius: 10, x:0.0, y: 15.0)

				.padding(.top, -450)
		)
	}
}

struct ResultsRow: View {
	let question: QuestionViewModel
	var body: some View {
		VStack(alignment: .leading) {
			Text("\(question.index + 1). \(question.questionTitle)")
				.font(.headline)
				.fontWeight(.bold)
				.foregroundStyle(PastelTheme.title)
				.padding(.bottom, 3)

			VStack(alignment: .leading) {
				ForEach(question.choices, id: \.self) { answer in
					VStack {
						HStack {
							icon(for: question, answer: answer)

							Text(answer.title)
								.foregroundStyle(PastelTheme.title)
							Spacer()
						}
						.background{
							RoundedRectangle(cornerRadius: CornerRadius)
								.fill(PastelTheme.answerRowBackground)
								.opacity(question.selectedChoices.contains(answer) ? 1 : 0)
						}

						Spacer()
							.frame(height: 1)
					}

				}
			}
		}
		.padding()
		.background {
			RoundedRectangle(cornerRadius: CornerRadius)
				.fill(PastelTheme.rowBackground)
				.shadow(color: .black.opacity(0.09), radius: 4, y: 2)
				.overlay {
					RoundedRectangle(cornerRadius: CornerRadius)
						.fill(PastelTheme.rowBackground.lighten)
						.offset(y: -4)
				}
		}
		.padding(.horizontal)
	}

	func icon(for question: QuestionViewModel, answer: Choice) -> some View {
		if question.selectedChoices.contains(answer) {
			return Image(systemName: question.answerState[answer] == .correct ? "xmark.circle" : "checkmark.circle")
				.foregroundColor(question.answerState[answer] == .correct ? PastelTheme.answerCorrectBackground : PastelTheme.answerWrongBackground)
		} else if answer.isAnswer {
			return Image(systemName: "checkmark.circle")
				.foregroundColor(.green)

		}else {
			return Image(systemName:"circle.dotted")
				.foregroundColor(PastelTheme.subTitle)

		}
	}

}
#Preview {
	@Previewable @State var exam = Exam(id: 00, questions: [], status: .unattempted)
	let result = ExamResult(exam: exam)
	ResultsView(result: result)
		.task {
			exam = await Exam.mock()
		}
}
