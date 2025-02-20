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

	@State private var showHintView = false
	@State private var dynamicHintHeight: CGFloat = 0.0
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
						_ = {print("show hint toggle")}
						Task {
							try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)

							withAnimation(Animation.easeInOut(duration: 0.3).delay(1.21)) {
								proxy.scrollTo(show ? bottomID : topID)
							}

						}
					}

					HintView()
						.transition(transition)
						.opacity(showHintView ? 1.0 : 0.0)
						.id(bottomID)

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
		VStack(spacing: 0.0) {
				ForEach(Array(viewModel.choices.enumerated()), id: \.offset) { index, choice in
					AnswerRow(answer: choice, isLastRow: isLastRow(index), answerState: viewModel.state(for: choice)) {
						selected($0)
					}
					.shake(viewModel.state(for: choice) == .wrong)
					.disabled(!viewModel.allowChoiceSelection)
				}
			}
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
		Text(viewModel.hint)
			.font(.callout)
			.lineSpacing(12.0)
			.foregroundStyle(.primary)
			.padding(.horizontal)
			.readHeight($dynamicHintHeight)
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
