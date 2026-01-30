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
	@Environment(Router.self) var router
	@State private var ringProgress = 0.0

	var body: some View {
		VStack {
			ScrollView {
				VStack (spacing: 10.0) {
					ResultsHeader()
						.padding(.bottom)
					ForEach(result.questionsViewModels) { viewModel in
						ResultsRow(viewModel: viewModel)
					}
					Spacer()

				}
				.onAppear {
					ringProgress = result.exam.score
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

							Text(result.score)
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
					Text("\(result.exam.incorrectQuestions.count)")
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

			if !viewModel.isFullyAnswered {
				Text("(Not fully answered)")
					.foregroundStyle(PastelTheme.subTitle)
			}
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
//								.fill(PastelTheme.rowBackground.darken(by: 0.01))
								.fill(backgroundColor(for: viewModel, choice: choice))
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
		switch viewModel.state(for: choice) {
			case .correct:
				Image(systemName: "checkmark.circle")
					.foregroundColor(viewModel.selectedChoices[choice] == .correct ? PastelTheme.title : PastelTheme.background)
			case .wrong:
				Image(systemName: "xmark.circle")
					.foregroundColor(PastelTheme.title)
			case .notAttempted:
				Image(systemName:"circle.dotted")
					.foregroundColor(PastelTheme.subTitle)
		}
	}

	func backgroundColor(for question: QuestionViewModel, choice: Choice) -> Color {
		switch viewModel.state(for: choice) {
			case .correct: PastelTheme.answerCorrectBackground.darken
			case .wrong: PastelTheme.answerWrongBackground.lighten(by: 0.4)
			case .notAttempted: Color.clear
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
			let mockExamViewModel = ExamViewModel(exam: exam)
			let answer0 = exam.questions[0].choices.filter({$0.isAnswer}).first!
			let answer1 = exam.questions[1].choices.filter({!$0.isAnswer}).first!
			let answer2 = exam.questions[2].choices.filter({!$0.isAnswer}).first!
			let answer3 = exam.questions[3].choices.filter({$0.isAnswer}).first!
			let answer4 = exam.questions[4].choices.filter({$0.isAnswer}).first!
			let answer5 = exam.questions[5].choices.filter({!$0.isAnswer}).first!


			mockExamViewModel.questions[0].selected(answer0)
			mockExamViewModel.questions[1].selected(answer1)
			mockExamViewModel.questions[2].selected(answer2)
			mockExamViewModel.questions[3].selected(answer3)
			mockExamViewModel.questions[4].selected(answer4)
			mockExamViewModel.questions[5].selected(answer5)

			let finishedExam = mockExamViewModel.finishExam(duration: 2*60)
			result = mockExamViewModel.resultViewModel
		}
}
