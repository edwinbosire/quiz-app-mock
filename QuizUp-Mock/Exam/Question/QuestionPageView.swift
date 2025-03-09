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

	private let topID = 0
	private let bottomID = 1

	var body: some View {
		GeometryReader { geo in
			ScrollViewReader { proxy in
				ScrollView {
					contentView(geo: geo, scrollProxy: proxy)
				} // ScrollView
				.useStickyHeaders()
				.coordinateSpace(name: "container")
//				.background(PastelTheme.background.gradient)
			} // ScrollViewProxy
		}// Georeader
	}

	@ViewBuilder
	func contentView(geo: GeometryProxy, scrollProxy: ScrollViewProxy) -> some View {
		VStack {
			VStack(alignment: .leading) {
				VStack {
					QuestionText()
						.layoutPriority(2)
						.id(topID)
						.zIndex(0)

					Rectangle()
						.fill(.clear)
						.sticky()
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
					if show {
						withAnimation(.easeInOut.delay(0.5)) {
							scrollProxy.scrollTo(bottomID)
						}
					}
				}
				.onAppear {
					if viewModel.showHint {
						withAnimation(.easeInOut.delay(0.5)) {
							scrollProxy.scrollTo(bottomID)
						}
					} else {
						scrollProxy.scrollTo(topID)
					}

				}
		}

	}

	@ViewBuilder
	func QuestionText() -> some View {
		VStack(alignment: .center) {
			Text(viewModel.questionTitle)
				.multilineTextAlignment(.center)
				.font(.title)
				.foregroundColor(PastelTheme.title)
				.padding(.horizontal)
				.transition(.opacity)
				.sticky()
				.frame(maxWidth: .infinity)


		}
		.frame(maxHeight: .infinity)

	}

	@ViewBuilder
	func PromptView() -> some View {
		HStack(alignment: .bottom) {
			Text(viewModel.prompt)
				.font(.subheadline)
				.foregroundColor(PastelTheme.subTitle)
				.padding(.leading)

			Spacer()
			if viewModel.showHint {
				Button {
					Task {
						await viewModel.owner?.progressToNextQuestions()
					}
				} label: {
					MovingRightIndicator()
				}
			}
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
		.padding()
	}

	func isLastRow(_ index: Int) -> Bool {
		index == viewModel.choices.count-1
	}

	@ViewBuilder
	func HintView() -> some View {
		VStack(alignment: .leading, spacing: 8.0) {
			HStack {
				Image(systemName: "info.circle")
					.foregroundStyle(PastelTheme.yellow)
					.padding(.trailing, 4.0)
				Text("Explanation")
					.foregroundStyle(PastelTheme.subTitle)
					.fontWeight(.semibold)

				Spacer()
			}
			.font(.footnote)

			Text(viewModel.hint)
				.font(.callout)
				.foregroundStyle(PastelTheme.title)
				.padding(.top, 4)
		}
		.padding()
		.background {
			RoundedRectangle(cornerRadius: CornerRadius)
				.fill(PastelTheme.background.lighten)
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
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Text("Mock Test")
						.font(.title3)
						.bold()
						.foregroundStyle(PastelTheme.title)
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
			.background(PastelTheme.background.gradient)

	}

}
