//
//  ResultsView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 13/03/2023.
//

import SwiftUI

struct ResultsView: View {
	let result: ExamResultViewModel
	var body: some View {
		ResultsViewContainer(result: result)
	}
}

struct ResultsViewContainer: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

	let result: ExamResultViewModel
	@EnvironmentObject var router: Router
	@State private var ringProgress = 0.0

	var score: String {
		"\(result.exam.correctQuestions.count) / \(result.exam.questions.count)"
	}

	var body: some View {
		VStack {
			ScrollView {
				VStack (spacing: 10.0) {
					ResultsHeader()
						.padding(.bottom)
					ForEach(Array(result.exam.questions.enumerated()), id: \.offset) { index, question in
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
					Text(String(format: "%0.1f %%",result.exam.scorePercentage))
						.font(.subheadline)
						.foregroundStyle(.secondary)
						.padding(.bottom, 8.0)

					Text("Wrong Answers")
						.font(.headline)
						.foregroundStyle(PastelTheme.title)
					Text("\(result.exam.correctQuestions.count)")
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

			VStack(alignment: .leading, spacing: 0.0) {
				ForEach(viewModel.choices, id: \.self) { choice in
					VStack {
						HStack {
							icon(for: viewModel, choice: choice)

							Text(choice.title)
								.foregroundStyle(PastelTheme.title)
							Spacer()
						}
						.padding(.vertical, 1.0)
						.padding(.horizontal, 5.0)
						.background {
							RoundedRectangle(cornerRadius: CornerRadius)
								.fill(PastelTheme.rowBackground.darken(by: 0.01))
								.opacity(viewModel.selectedChoices[choice] == nil ? 0 : 1)
						}
					}
				}
			}
		}
		.padding()
		.pastelThemeBackground(PastelTheme.rowBackground)
		.padding(.horizontal)
	}

	@ViewBuilder
	func icon(for question: QuestionViewModel, choice: Choice) -> some View {
		if let attempted = question.selectedChoices[choice] {
			switch attempted {
				case .correct:
					 Image(systemName: "checkmark.circle")
						.foregroundColor(PastelTheme.answerCorrectBackground)
				case .wrong:
					 Image(systemName: "xmark.circle")
						.foregroundColor(PastelTheme.answerWrongBackground)
				case .notAttempted:
					 Image(systemName:"circle.dotted")
						.foregroundColor(PastelTheme.subTitle)
			}
		} else if choice.isAnswer {
			 Image(systemName: "checkmark.circle")
				.foregroundColor(PastelTheme.answerCorrectBackground)
				.bold()

		} else {
			 Image(systemName:"circle.dotted")
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
	var _result: ExamResultViewModel?
	var result: ExamResultViewModel {
		get {
			if let _result {
				return _result
			}

			let exam = Exam(id: 00, questions: [])
			let mockExam = AttemptedExam(from: exam)
			return ExamResultViewModel(exam: mockExam)
		}
		set {
			_result = newValue
		}
	}

	ResultsView(result: result)
		.task {
			let exam = await Exam.mock()
			var mockExam = AttemptedExam(from: exam)

			let answer = exam.questions[0].choices.filter(\Choice.isAnswer).first!
			mockExam.update(selectedChoices: [answer: .correct])

			let answer2 = exam.questions[1].choices.filter(\Choice.isAnswer).first!
			mockExam.update(selectedChoices: [answer: .correct])

			result = ExamResultViewModel(exam: mockExam)
		}
}
