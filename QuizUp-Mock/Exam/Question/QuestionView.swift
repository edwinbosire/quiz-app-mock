//
//  QuestionView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 10/03/2023.
//

import SwiftUI

struct QuestionView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

	@ObservedObject var viewModel: ExamViewModel
	@Binding var route: Route
	var namespace: Namespace.ID

	@State private var selectedPage: Int = 0
	@State private var isShowingMenu: Bool = false
	@State private var promptRestartExam: Bool = false

	var body: some View {
			ZStack {
				VStack {
					ExamProgressView(currentPage: $viewModel.progress, pages: viewModel.questions.count)
					HStack(alignment: .firstTextBaseline) {
						QuestionCounter(progressTitle: viewModel.progressTitle)
						Spacer()
						TimerView()
					}
					.padding(.top)

					TabView(selection: $viewModel.progress) {
						ForEach(viewModel.questions) { question in
							QuestionPageContent(viewModel: question)
								.frame(maxWidth: .infinity)
								.frame(maxHeight: .infinity)
								.tag(question.index)
						}
					}
					.tabViewStyle(.page(indexDisplayMode: .never))
					Spacer()
					Spacer()
				}

			}
			.gradientBackground()
			.onAppear {
				selectedPage = viewModel.progress
			}
			.onChange(of: viewModel.progress) { newValue in
				selectedPage = newValue
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Text("Mock Test")
						.matchedGeometryEffect(id: "mockTestTitle-0", in: namespace)
						.font(.title3)
						.bold()
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					HStack {
						Button(action: {viewModel.bookmarked.toggle()}) {
							Image(systemName: viewModel.bookmarked ? "bookmark.fill" : "bookmark")

						}

						Button(action: {isShowingMenu.toggle()}) {
							Image(systemName: isShowingMenu ? "ellipsis.circle.fill" : "ellipsis.circle")
						}
					}
					.foregroundColor(.paletteBlue)
				}
			}
			.actionSheet(isPresented: $isShowingMenu) {
				ActionSheet(title: Text(""), message: nil, buttons: [
					.default(Text("Report Issue")),
					.default(Text("Restart Test")){ promptRestartExam.toggle() },
					.default(Text("Quit Test")){ presentationMode.wrappedValue.dismiss()},
					.cancel()

				])
			}
			.alert("Restart Exam?", isPresented: $promptRestartExam, actions: {
				Button("Cancel", role: .cancel, action: {})
				Button("Restart", role: .destructive, action: { restartExam()})
			}, message: {
				Text("You will lose all progress")
			})
	}

	func restartExam() {
		_ = viewModel.restartExam()
	}

}

struct TimerView: View {
	@Environment(\.colorScheme) var colorScheme
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	@State var timeRemaining = 25*60
	@State var minutes = 00
	@State var seconds = 00
	var body: some View {
		HStack {
			Image(systemName: "clock")
				.foregroundStyle(.tertiary)
				.font(.subheadline)

			Text(String(format: "%02d : %02d", minutes, seconds))
				.font(.subheadline)
				.monospacedDigit()
				.padding(.trailing)
				.foregroundStyle(.tertiary)
				.shadow(color: colorScheme == .dark ? .clear : Color.white.opacity(0.5), radius: 1, x: 2, y: 1)

		}
		.background(.clear)
		.onReceive(timer) { t in
			if timeRemaining > 0 {
				timeRemaining -= 1

				minutes = (timeRemaining % 3600) / 60
				seconds = (timeRemaining % 3600) % 60
			} else {
				minutes = 00
				seconds = 00
			}
		}
	}
}

struct ExamProgressView: View {
	@Environment(\.colorScheme) var colorScheme
	@Binding var currentPage: Int
	let pages: Int

	var body: some View {
		GeometryReader { reader in
			HStack(spacing: 0) {
				ForEach(0..<pages, id:\.self) { i in
					Rectangle()
						.fill( fillColor(at: i))
						.border(colorScheme == .dark ? .black.opacity(0.08) : .white.opacity(0.07))
						.animation(.easeIn, value: i)
				}
			}

		}
		.frame(height: 5)
	}


	func fillColor(at index: Int) -> Color {
		if  index < currentPage {
			return Color.progressBarTint
		} else if currentPage == index {
			return Color.paletteBlue.opacity(0.5)
		}
		return Color.paletteBlue.opacity(0.1)
	}
}

struct QuestionPageContent: View {
	@Environment(\.colorScheme) var colorScheme
	@ObservedObject var viewModel: QuestionViewModel

	let transition = AnyTransition.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)).combined(with: .opacity)

	@Namespace var topID
	@Namespace var bottomID

	@State private var showHintView = false
	var body: some View {
		GeometryReader { geometry in
			ScrollView {
				ScrollViewReader { proxy in
					VStack(alignment: .leading) {
						titleView()
							.frame(maxHeight: .infinity)
							.id(topID)
						Spacer()
						promptView()
						Spacer()
						answersView()
					}
					.frame(height: geometry.size.height)
					.listRowInsets(EdgeInsets())
					.listRowBackground(Color.defaultBackground.opacity(0.9))
					.onChange(of: showHintView) { show in
						_ = {print("show hint toggle")}
						withAnimation {
							proxy.scrollTo(show ? bottomID : topID)
						}
					}

					hintView()
						.transition(transition)
						.opacity(showHintView ? 1.0 : 0.0)
						.id(bottomID)
						.animation(.easeIn, value: showHintView)

				} // ScrollViewProxy
			} // ScrollView
		}// Georeader
		.onChange(of: viewModel.showHint) { newValue in
			self.showHintView = newValue
		}
		.onAppear {
			self.showHintView = false
		}
	}

	func titleView() -> some View {
		VStack(alignment: .center) {
			Text(viewModel.title)
				.multilineTextAlignment(.center)
				.font(.title)
				.foregroundColor(Color.paletteBlueDark)
				.padding(.horizontal)
				.shadow(color: colorScheme == .dark ? .clear : .white.opacity(0.5), radius: 1, x: 2, y: 1)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)

	}

	func promptView() -> some View {
		Text(viewModel.prompt)
			.foregroundStyle(.tertiary)
			.font(.subheadline)
			.foregroundColor(.subTitleText)
			.padding(.leading)
			.shadow(color: colorScheme == .dark ? .clear : Color.white, radius: 1, x: 2, y: 1)
	}

	func answersView() -> some View {
		VStack(spacing: 0.0) {
				ForEach(Array(viewModel.options.enumerated()), id: \.offset) { index, answer in
					AnswerRow(answer: answer, isLastRow: (index == viewModel.options.count-1), answerState: viewModel.state(for: answer)) { selected in
						withAnimation(.easeInOut(duration: 0.3)) {
							viewModel.selected(selected)
//							showHintView.toggle()
						}
					}
					.modifier(viewModel.state(for: answer) == .wrong ? Shake(animatableData: 1.0) : Shake(animatableData: 0.0))
				}
			}
//			.background(.ultraThinMaterial)
			.background(
				Color.rowBackground
					.background(.ultraThinMaterial)
					.shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.1), radius: 9, x: 0, y: -1)
			)
	}

	func hintView() -> some View {
		Text(viewModel.hint)
			.font(.callout)
			.lineSpacing(12.0)
			.foregroundStyle(.primary)
			.padding(.horizontal)
	}

}

struct QuestionCounter: View {
	@Environment(\.colorScheme) var colorScheme
	let progressTitle: String
	var isLightappearance: Bool { colorScheme == .light}
	var body: some View {
		HStack {
			Text(progressTitle)
				.font(.subheadline)
				.monospacedDigit()
				.foregroundColor(Color.subTitleText )
				.foregroundStyle(.tertiary)
				.padding(.horizontal)
				.padding(.vertical, 5.0)
			Spacer()
		}
		.padding(.bottom)
		.padding(.horizontal)

	}
}


struct QuestionView_Previews: PreviewProvider {
	@Namespace static var namespace
	static var previews: some View {
		let viewModel = ExamViewModel.mock()

		QuestionView(viewModel: viewModel, route: .constant(.mockTest(testId: 0)), namespace: namespace)
	}
}
