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

	@State private var showHintView = true
	@State private var dynamicQuestionHeight: CGFloat = 0.0

	var body: some View {
		GeometryReader { geometry in
			ScrollView {
				ScrollViewReader { proxy in
					VStack(alignment: .leading) {
						GeometryReader { geo in
							let offsetY = geo.frame(in: .global).minY
							QuestionText()
								.frame(maxHeight: .infinity)
								.id(topID)
								.offset(y: offsetY < 25.0 ? -offsetY : 0.0)
						}
						Spacer()
						PromptView()
						Spacer()
						AnswersView()
					}
					.frame(height: geometry.size.height)
					.listRowInsets(EdgeInsets())
					.listRowBackground(Color.defaultBackground.opacity(0.9))
					.onChange(of: showHintView) { _, show in
						withAnimation(Animation.easeInOut) {
							proxy.scrollTo(show ? bottomID : topID)
						}
					}

						HintView()
							.opacity(showHintView ? 1.0 : 0.0)
							.id(bottomID)
							.animation(.easeInOut.delay(0.3), value: showHintView)

				} // ScrollViewProxy
			} // ScrollView
		}// Georeader
		.onChange(of: viewModel.showHint) { _,  newValue in
			withAnimation(Animation.easeInOut(duration: 0.3).delay(1.5)) {
				self.showHintView = newValue
			}
		}
		.onAppear {
			self.showHintView = false
		}
	}

	@ViewBuilder
	func QuestionText() -> some View {
		VStack(alignment: .center) {
			Text(viewModel.questionTitle)
				.multilineTextAlignment(.center)
				.font(.title)
				.foregroundStyle(.primary)
				.foregroundColor(Color.paletteBlueDark)
				.padding(.horizontal)
				.shadow(color: colorScheme == .dark ? .clear : .white.opacity(0.5), radius: 1, x: 2.0, y: 1)
				.readHeight($dynamicQuestionHeight)

		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)

	}

	@ViewBuilder
	func PromptView() -> some View {
		HStack(alignment: .bottom) {
			Text(viewModel.prompt)
				.foregroundStyle(.tertiary)
				.font(.subheadline)
				.foregroundColor(.secondary)
				.padding(.leading)

			Spacer()
			if showHintView {
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
		.padding()
		.background(
			Color.rowBackground
				.background(.ultraThinMaterial)
				.shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.1), radius: 9, x: 0, y: -1)
		)


	}

	func isLastRow(_ index: Int) -> Bool {
		index == viewModel.choices.count-1
	}

	@ViewBuilder
	func HintView() -> some View {
		VStack(spacing: 8.0) {
			HStack {
				Image(systemName: "info.circle")
					.foregroundStyle(Color.blue)
					.padding(.trailing, 4.0)
				Text("Explanation")
					.foregroundStyle(.secondary)

				Spacer()
			}
			.font(.footnote)
//			.padding()

			Text(viewModel.hint)
				.font(.callout)
				.foregroundStyle(.primary)
				.padding(.top, 4)
		}
		.padding()
		.background {
			RoundedRectangle(cornerRadius: 8.0)
				.fill(Color.blue.opacity(0.1))
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
