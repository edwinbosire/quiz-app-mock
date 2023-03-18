//
//  QuestionView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 10/03/2023.
//

import SwiftUI

struct QuestionView: View {
	@ObservedObject var viewModel: ExamViewModel
	@Binding var route: Route
	@State private var selectedPage: Int = 0
	@State private var isShowingMenu: Bool = false
	var body: some View {
		NavigationView {
			ZStack {
				Color("Background")
					.opacity(0.9)
					.ignoresSafeArea()
				VStack {
					ProgressView(currentPage: $viewModel.progress, pages: viewModel.questions.count)
					HStack(alignment: .firstTextBaseline) {
						QuestionCounter(progressTitle: viewModel.progressTitle)
						Spacer()
						TimerView()
					}

					GeometryReader { geo in
						TabView(selection: $viewModel.progress) {
							ForEach(viewModel.availableQuestions) { question in
								QuestionPageContent(viewModel: question)
									.frame(width: geo.size.width)
									.tag(question.index)
							}
						}
						.tabViewStyle(.page(indexDisplayMode: .never))
						.animation(.easeInOut(duration: 0.4), value: viewModel.progress)

					}
					Spacer()
					Spacer()
				}

			}
			.onAppear {
				selectedPage = viewModel.progress
			}
			.onChange(of: viewModel.progress) { newValue in
				selectedPage = newValue
			}
//			.navigationTitle("Mock Test")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Text("Mock Test")
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
					.default(Text("Restart Test")),
					.default(Text("Quit Test")){ route = .mainMenu},
					.cancel()

				])
			}
		}


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
			Text(String(format: "%02d : %02d", minutes, seconds))
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

struct ProgressView: View {
	@Binding var currentPage: Int
	let pages: Int

	var body: some View {
		GeometryReader { reader in
			HStack(spacing: 0) {
				ForEach(0..<pages, id:\.self) { i in
					Rectangle()
						.fill( fillColor(at: i))
						.border(.white.opacity(0.1))
						.animation(.easeIn, value: i)
				}
			}

		}
		.frame(height: 5)
	}


	func fillColor(at index: Int) -> Color {
		if  index < currentPage {
			return Color.paletteBlue
		} else if currentPage == index {
			return Color.paletteBlue.opacity(0.5)
		}
		return Color.paletteBlue.opacity(0.1)
	}
}

struct QuestionPageContent: View {
	@Environment(\.colorScheme) var colorScheme
	@ObservedObject var viewModel: QuestionViewModel

	@State var showHint = false

	var body: some View {
			GeometryReader { geometry in
				ScrollView(showsIndicators: false) {
					VStack(alignment: .leading) {
						Spacer()
						VStack(alignment: .center) {
							Text(viewModel.title)
								.multilineTextAlignment(.center)
								.font(.title)
								.foregroundColor(Color.paletteBlueDark)
								.padding(.horizontal)
								.shadow(color: colorScheme == .dark ? .clear : .white.opacity(0.5), radius: 1, x: 2, y: 1)
						}
						.frame(maxWidth: .infinity)
						Spacer()

						Spacer()
						Text(viewModel.prompt)
							.foregroundStyle(.tertiary)
							.font(.callout)
							.padding(.leading)
							.shadow(color: colorScheme == .dark ? .clear : Color.white, radius: 1, x: 2, y: 1)

						ZStack {
							Color("RowBackground2")
								.shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.1), radius: 9, x: 0, y: -1)

								LazyVStack {
									ForEach(Array(viewModel.options.enumerated()), id: \.offset) { index, answer in
										AnswerRow(answer: answer, isLastRow: (index == viewModel.options.count-1), answerState: viewModel.state(for: answer)) { selected in
											withAnimation {
												viewModel.selected(selected)
											}
											if !selected.isAnswer {
												showHint.toggle()
											}

										}
										.modifier(viewModel.state(for: answer) == .wrong ? Shake(animatableData: 1.0) : Shake(animatableData: 0.0))

									}
								}
									.background(Color("RowBackground2"))
							

					}
						.fixedSize(horizontal: false, vertical: true)


						if showHint {
							Text(viewModel.hint)
								.font(.callout)
								.foregroundStyle(.tertiary)
								.padding(.horizontal)
								.opacity(showHint ? 1 : 0)
								.animation(.easeInOut(duration: 10), value: showHint)
						}
					}
					.frame(minHeight: geometry.size.height)
				} //ScrollView
			}// GeometryReader
	} // Body
}

struct QuestionCounter: View {
	@Environment(\.colorScheme) var colorScheme
	let progressTitle: String
	var isLightappearance: Bool { colorScheme == .light}
	var body: some View {
		HStack {
			Text(progressTitle)
				.monospacedDigit()
				.foregroundColor(.white)
				.padding(.horizontal)
				.padding(.vertical, 5.0)
				.background(RoundedRectangle(cornerRadius: 50.0)
					.fill(Color.paletteBlue.opacity(isLightappearance ? 1.0 : 0.3).gradient)
					.shadow(color: Color.black.opacity(0.3), radius: 5, x: 2, y: 4)
				)
			Spacer()
		}
		.padding(.bottom)
		.padding(.horizontal)

	}
}


struct QuestionView_Previews: PreviewProvider {
	static var previews: some View {
		let viewModel = ExamViewModel.mock()
		QuestionView(viewModel: viewModel, route: .constant(.mockTest))
	}
}
