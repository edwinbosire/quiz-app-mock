//
//  AnswerRow.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 11/03/2023.
//

import SwiftUI

struct AnswerRow: View {
	@Environment(\.colorScheme) var colorScheme
	let answer: Choice
	let isLastRow: Bool
	let answerState: AttemptedQuestion.State
	var selected: ((Choice) -> Void)?
	private var isDarkMode: Bool { colorScheme == .dark }

	@State var attempts: Int = 0

	init(answer: Choice, isLastRow: Bool = false, answerState: AttemptedQuestion.State, selected: ((Choice) -> Void)? = nil) {
		self.answer = answer
		self.isLastRow = isLastRow
		self.answerState = answerState
		self.selected = selected
	}

	var body: some View {
		HStack {
			Image(systemName: radialImage)
//				.symbolRenderingMode(.palette)
				.foregroundColor(titleForegroundColor)
				.frame(width: 24, height: 24)
				.animation(.spring, value: answerState)
				.transition(.move(edge: .bottom))

			Text(answer.title)
				.font(.body)
				.fontWeight(.medium)
//				.font(.system(size: 16))
				.lineLimit(3)
				.allowsTightening(true)
				.minimumScaleFactor(0.5)
				.foregroundColor(titleForegroundColor)
				.frame(maxWidth: .infinity, alignment: .leading)
		}
		.padding()
		.padding(.trailing, 4.0)
		.background(
			RoundedRectangle(cornerRadius: CornerRadius)
				.fill(background.darken)
				.overlay {
					RoundedRectangle(cornerRadius: CornerRadius)
						.fill(background.lighten)
						.offset(y: -4.0)
				}
		)
		.contentShape(Rectangle())
		.onTapGesture {
			selected?(answer)
			haptic(answer.isAnswer)
		}
	}

	var titleForegroundColor: Color {
		switch answerState {
			case .notAttempted:
				return PastelTheme.green
			case .correct:
				return .white
			case .wrong:
				return .white
		}
	}

	var radialImageBackgroundPrimary: Color {
		switch answerState {
			case .notAttempted:
				return .paletteBlue
			case .correct:
				return .white
			case .wrong:
				return .white
		}
	}
	var radialImageBackgroundSecondary: Color {
		switch answerState {
			case .notAttempted:
				return .paletteBlue
			case .correct:
				return .white
			case .wrong:
				return .white
		}
	}

	var radialImage: String {
		switch answerState {
			case .notAttempted:
				return "circle"
			case .correct:
				return "checkmark.circle"
			case .wrong:
				return "xmark.circle.fill"
		}
	}

	var background: Color {
		switch answerState {
			case .notAttempted:
				return PastelTheme.answerRowBackground
			case .correct:
				return PastelTheme.answerCorrectBackground
			case .wrong:
				return PastelTheme.answerWrongBackground
		}
	}

	var mediumImpact: UIImpactFeedbackGenerator {
		UIImpactFeedbackGenerator(style: .medium)
	}
	var selectionFeedback: UISelectionFeedbackGenerator {
		UISelectionFeedbackGenerator()
	}
	func haptic(_ type: Bool) {
		if type {
			selectionFeedback.prepare()
			selectionFeedback.selectionChanged()
		} else {
			let generator = UINotificationFeedbackGenerator()
			generator.notificationOccurred(.success)
		}
	}

}

struct AnswerRow_Previews: PreviewProvider {
	static var previews: some View {
		@State var viewModel = QuestionViewModel.empty()
		@State var answer1 = Choice(title: "")
		@State var answer2 = Choice(title: "")
		@State var answer3 = Choice(title: "")

		Group {

			AnswerRow(answer: answer1, answerState: .notAttempted)
			.previewLayout(PreviewLayout.sizeThatFits)
			.padding()
			.previewDisplayName("Default")

			AnswerRow(answer: answer2, answerState: .wrong)
				.previewLayout(PreviewLayout.sizeThatFits)
				.padding()
				.previewDisplayName("Wrong answer")

			AnswerRow(answer: answer3, isLastRow: true, answerState: .correct)
				.previewLayout(PreviewLayout.sizeThatFits)
				.padding()
				.previewDisplayName("correct answer")
		}
		.background(Backgrounds())
		.task {
			viewModel = await QuestionViewModel.mock()
			answer1 = viewModel.choices[1]
			answer2 = viewModel.choices[2]
			answer3 = viewModel.choices[3]
		}
	}
}

extension Binding {
	static func mock(_ value: Value) -> Self {
		var value = value
		return Binding(get: { value },
					   set: { value = $0 })
	}
}
