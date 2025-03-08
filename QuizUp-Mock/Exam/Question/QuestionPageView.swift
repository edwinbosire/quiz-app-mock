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
				.background(PastelTheme.background)
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

extension View {
	func useStickyHeaders() -> some View {
		modifier(UseStickyHeaders())
	}
}

struct UseStickyHeaders: ViewModifier {
	@State private var frames: StickyRects.Value = [:]

	func body(content: Content) -> some View {
		content
			.onPreferenceChange(FramePreference.self) {
				frames = $0
			}
			.environment(\.stickyRects, frames)
	}
}

extension View {
	func sticky() -> some View {
		modifier(Sticky())
	}
}

struct Sticky: ViewModifier {
	@Environment(\.stickyRects) var stickyRects
	@State private var frame: CGRect = .zero
	@Namespace private var id

	var isSticking: Bool {
		frame.minY < 0
	}

	var offset: CGFloat {
		guard isSticking else { return 0 }
		guard let stickyRects else {
			print("Warning: Using .sticky() without .useStickyHeaders()")
			return 0
		}
		var o = -frame.minY
		if let other = stickyRects.first(where: { (key, value) in
			key != id && value.minY > frame.minY && value.minY < frame.height
		}) {
			o -= frame.height - other.value.minY
		}

		return o
	}

	func body(content: Content) -> some View {
		content
			.offset(y: offset)
			.zIndex(isSticking ? .infinity : 0)
			.overlay(GeometryReader { proxy in
				let f = proxy.frame(in: .named("container"))
				Color.clear
					.onAppear { frame = f }
					.onChange(of: f) {_, newFrame in
						frame = newFrame
					}
					.preference(key: FramePreference.self, value: [id: frame])
			})


	}
}

struct FramePreference: PreferenceKey {
	static var defaultValue: [Namespace.ID: CGRect] = [:]

	static func reduce(value: inout Value, nextValue: () -> Value) {
		value.merge(nextValue()) { $1 }
	}
}

enum StickyRects: EnvironmentKey {
	static var defaultValue: [Namespace.ID: CGRect]? = nil
}

extension EnvironmentValues {
	var stickyRects: StickyRects.Value {
		get { self[StickyRects.self] }
		set { self[StickyRects.self] = newValue }
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
			.background(PastelTheme.background)

	}

}
