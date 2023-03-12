//
//  AnswerRow.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 11/03/2023.
//

import SwiftUI

enum AnswerState {
	case correct
	case wrong
	case notAttempted
}

struct AnswerRow: View {
	@State var selectedAnswer: Answer?
	let answer: Answer
	let isLastRow: Bool
	let answerState: AnswerState
	var selected: ((Answer) -> Void)?

	@State var attempts: Int = 0
//	@State var radialImage: String  = "circle"

	init(answer: Answer, isLastRow: Bool = false, answerState: AnswerState, selected: ( (Answer) -> Void)? = nil) {
		self.answer = answer
		self.isLastRow = isLastRow
		self.answerState = answerState
		self.selected = selected
	}

	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Image(systemName: radialImage)
					.symbolRenderingMode(.palette)
					.foregroundStyle(Color.paletteBlue, Color.paletteBlueDark)

				Text(answer.title)
					.font(.title3)
					.foregroundColor(.paletteBlueSecondaryDark)
					.padding(.vertical, 12)
			}
			.padding(.leading)
			Divider()
				.padding(.leading, isLastRow ? 0 : 20)
		}
		.contentShape(Rectangle())
		.background(background)
		.onTapGesture {
//			withAnimation {
				selected?(answer)
//			}
		}
	}

	var radialImage: String {
		switch answerState {
			case .notAttempted:
				return "circle"
			case .correct:
				return "checkmark.circle"
			case .wrong:
				return "xmark.circle"
		}
	}

	var background: Color {
		switch answerState {
			case .notAttempted:
				return .white
			case .correct:
				return .green
			case .wrong:
				return .pink
		}
	}
}

struct AnswerRow_Previews: PreviewProvider {
	static var previews: some View {
		let viewModel = QuestionViewModel.mock()
		let answer1 = viewModel.options[1]
		let answer2 = viewModel.options[2]
		let answer3 = viewModel.options[3]
		Group {
			AnswerRow(answer: answer1, answerState: .notAttempted)  { selectedAnswer in
				print("user selected \(selectedAnswer.title)")
			}
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
	}
}

extension Binding {
  static func mock(_ value: Value) -> Self {
	var value = value
	return Binding(get: { value },
				   set: { value = $0 })
  }
}
