//
//  QuestionPageView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 31/01/2025.
//

import SwiftUI

struct QuestionPageView: View {
	@Environment(\.colorScheme) var colorScheme
	@ObservedObject var viewModel: QuestionViewModel

	let transition = AnyTransition.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)).combined(with: .opacity)

	@Namespace var topID
	@Namespace var bottomID

	var body: some View {
		GeometryReader { geo in
			ScrollViewReader { proxy in
				ScrollView {
					VStack {
						VStack(alignment: .leading) {
							VStack {
								QuestionText()
									.layoutPriority(2)
									.id(topID)
								Spacer()
								PromptView()
							}
							Spacer()
							AnswersView()
								.layoutPriority(1)
						}
						.frame(width: geo.size.width, height: geo.size.height)

						HintView()
							.opacity(viewModel.showHint ? 1.0 : 0.0)
							.id(bottomID)
							.animation(.easeInOut.delay(0.3), value: viewModel.showHint)
							.onChange(of: viewModel.showHint) { _, show in
								withAnimation(.easeInOut.delay(0.5)) {
									proxy.scrollTo(show ? bottomID : topID)
								}
							}
					}

				} // ScrollView
			} // ScrollViewProxy
		}// Georeader
	}

	@ViewBuilder
	func QuestionText() -> some View {
		VStack(alignment: .center) {
			Text(viewModel.questionTitle)
				.multilineTextAlignment(.center)
				.font(.title)
				.foregroundColor(PastelTheme.title)
				.padding(.horizontal)
//				.shadow(color: colorScheme == .dark ? .clear : .white.opacity(0.5), radius: 1, x: 2.0, y: 1)

		}
		.frame(maxWidth: .infinity)

	}

	@ViewBuilder
	func PromptView() -> some View {
		HStack(alignment: .bottom) {
			Text(viewModel.prompt)
				.font(.subheadline)
				.foregroundColor(PastelTheme.subTitle)
				.padding(.leading)

			Spacer()
			Button {
				Task {
					await viewModel.owner?.progressToNextQuestions()
				}
			} label: {
				MovingRightIndicator()
			}
			.opacity(viewModel.showHint ? 1.0 : 0.0)

		}
	}

	@ViewBuilder
	func AnswersView() -> some View {
		VStack(alignment: .leading) {
			ForEach(Array(viewModel.choices.enumerated()), id: \.offset) { index, choice in
				AnswerRow(answer: choice,
						  isLastRow: isLastRow(index),
						  answerState: viewModel.state(for: choice)) {
					selected($0)
				}
						  .shake(viewModel.state(for: choice) == .wrong)
						  .disabled(!viewModel.allowChoiceSelection)
			}
		}
		.listRowInsets(EdgeInsets())
		.listRowBackground(PastelTheme.background)
		.padding()
		.background(
			PastelTheme.background
				.background(.ultraThinMaterial)
				.shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.1), radius: 9, x: 0, y: -1)
		)


	}

	func isLastRow(_ index: Int) -> Bool {
		index == viewModel.choices.count-1
	}

	@ViewBuilder
	func HintView() -> some View {
		VStack(alignment: .leading, spacing: 8.0) {
			HStack {
				Image(systemName: "info.circle")
					.foregroundStyle(Color.blue)
					.padding(.trailing, 4.0)
				Text("Explanation")
					.foregroundStyle(.secondary)

				Spacer()
			}
			.font(.footnote)

			Text(viewModel.hint)
				.font(.callout)
				.foregroundStyle(.primary)
				.padding(.top, 4)
		}
		.padding()
		.background {
			RoundedRectangle(cornerRadius: CornerRadius)
				.fill(Color(UIColor.systemGray6))
//				.background(Color(UIColor.systemGray6))
				.shadow(color: .black.opacity(0.09), radius: 4, y: 2)
		}
		.padding()
	}

	func selected(_ answer: Choice) -> Void {
		withAnimation(.easeInOut(duration: 0.3)) {
			viewModel.selected(answer)
		}
	}
}

#Preview {
	@Previewable @State var viewModel = QuestionViewModel.empty()
	NavigationStack {


		QuestionPageView(viewModel: viewModel)
			.task {
				viewModel = await PreviewModel.mockQuestionViewModel()
			}
			.gradientBackground()
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Text("Mock Test")
						.font(.title3)
						.bold()
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					HStack {
						Button(action: {}) {
							Image(systemName:"bookmark")

						}

						Button(action: {}) {
							Image(systemName: "ellipsis.circle")
						}
					}
					.foregroundColor(.paletteBlue)
				}
			}
	}

}
