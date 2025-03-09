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
						ResultsRow(viewModel: QuestionViewModel(question: question, index: index))
					}
					Spacer()

				}
				.onAppear {
					ringProgress = 0.9//result.score
				}
			}

//			HStack {
//				TryAgainButton()
//				NextQuizButton()
//			}
//			.padding(.horizontal)


		}
		.overlay(ConfettiView())
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
			.background(
				RoundedRectangle(cornerRadius: CornerRadius)
					.fill(PastelTheme.background)
				.shadow(color: .black.opacity(0.09), radius: 4, y: 2)
			)

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
						.foregroundStyle(PastelTheme.yellow)
				}
			}
			.padding(.bottom)

			HStack {

				CircularProgressView(progress: $ringProgress, primaryColors: [Color.red, Color.red, Color.red, Color.green, Color.green].map{$0.lighten}, secondaryColor: PastelTheme.background)
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

			Text(result.prompt)
				.font(.title3)
				.fontWeight(.bold)
				.foregroundStyle(PastelTheme.title)
				.multilineTextAlignment(.center)
				.padding(.bottom)

		}
		.padding(.horizontal, 20)
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
	let viewModel: QuestionViewModel

	var body: some View {
		VStack(alignment: .leading) {
			Text("\(viewModel.index + 1). \(viewModel.questionTitle)")
				.font(.headline)
				.fontWeight(.bold)
				.foregroundStyle(PastelTheme.title)
				.padding(.bottom, 3)

			VStack(alignment: .leading) {
				ForEach(viewModel.choices, id: \.self) { choice in
					VStack {
						HStack {
							icon(for: viewModel, choice: choice)

							Text(choice.title)
								.foregroundStyle(PastelTheme.title)
							Spacer()
						}
						.background{
							RoundedRectangle(cornerRadius: CornerRadius)
								.fill(PastelTheme.answerRowBackground)
								.opacity(viewModel.selectedChoices.contains(choice) ? 1 : 0)
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

	func icon(for question: QuestionViewModel, choice: Choice) -> some View {
		if question.selectedChoices.contains(choice) {
			return Image(systemName: question.answerState[choice] == .correct ? "xmark.circle" : "checkmark.circle")
				.foregroundColor(question.answerState[choice] == .correct ? PastelTheme.answerCorrectBackground : PastelTheme.answerWrongBackground)
		} else if choice.isAnswer {
			return Image(systemName: "checkmark.circle")
				.foregroundColor(.green)

		} else {
			return Image(systemName:"circle.dotted")
				.foregroundColor(PastelTheme.subTitle)

		}
	}
}


struct ConfettiView: View {
	var randomColor: Color {
		Color(
			.init(
				red: .random(in: 0...1),
				green: .random(in: 0...1),
				blue: .random(in: 0...1)
			)
		)
	}

	var body: some View {

		ZStack {
			ForEach(0...11, id: \.self) {_ in
				Rectangle()
					.fill(randomColor)
					.frame(width: 12, height: 12)
					.modifier(ParticlesModifier())
					.offset(x: CGFloat.random(in: -100...100), y : CGFloat.random(in: -400...10))
			}
		}
	}
}

#Preview {
	@Previewable @State var exam = Exam(id: 00, questions: [], status: .unattempted)
	let result = ExamResult(exam: exam)
	ResultsView(result: result)
		.task {
			var finishedExam = await Exam.mock()
			let question1 = finishedExam.questions[0]
			finishedExam.userSelectedAnswer[question1.id] = question1.choices.filter{$0.isAnswer}

			let question2 = finishedExam.questions[2]
			finishedExam.userSelectedAnswer[question2.id] = question2.choices.filter{!$0.isAnswer}

			exam = finishedExam
		}
}
