//
//  QuestionView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 10/03/2023.
//

import SwiftUI

struct QuestionView: View {
	@ObservedObject var viewModel: ExamViewModel

	@State private var selectedPage: Int = 0
	var body: some View {
		ZStack {
			Color.black.opacity(0.1)
				.ignoresSafeArea()
			VStack {
				ProgressView(currentPage: $viewModel.progress)
				TimerView()
				QuestionCounter(progressTitle: viewModel.progressTitle)

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
	}
}

struct TimerView: View {
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	@State var timeRemaining = 25*60
	@State var minutes = 00
	@State var seconds = 00
	var body: some View {
		HStack {
			Spacer()
			Text("\(minutes) : \(seconds)")
				.monospacedDigit()
				.padding(.trailing)
				.foregroundStyle(.tertiary)
				.shadow(color: Color.white.opacity(0.5), radius: 1, x: 2, y: 1)

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
	let width: Int = 25
	@Binding var currentPage: Int

	var body: some View {
		GeometryReader { reader in
			HStack(spacing: 0) {
				ForEach(0..<width, id:\.self) { i in
					Rectangle()
						.fill( fillColor(at: i))
						.border(.white.opacity(0.1))
				}
			}

		}
		.frame(height: 5)
	}


	func fillColor(at index: Int) -> Color {
		if  index < currentPage {
			return Color.paletteBlue.opacity(0.5)
		} else if currentPage == index {
			return Color.paletteBlue
		}
		return Color.paletteBlue.opacity(0.1)
	}
}

struct QuestionPageContent: View {
	@ObservedObject var viewModel: QuestionViewModel

	@State var showHint = false

	var body: some View {
		VStack(alignment: .leading, spacing: 0.0) {

			GeometryReader { geometry in
				ScrollView(showsIndicators: false) {
					VStack(alignment: .leading) {
						Spacer()
						Text(viewModel.title)
							.font(.title)
							.foregroundColor(Color.paletteBlueDark)
							.padding(.horizontal)
							.shadow(color: Color.white.opacity(0.5), radius: 1, x: 2, y: 1)

						Spacer()

						Spacer()
						Text(viewModel.prompt)
							.foregroundStyle(.tertiary)
							.font(.callout)
							.padding(.leading)
							.shadow(color: Color.white, radius: 1, x: 2, y: 1)

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
						.background(.white)

						if showHint {
							Text(viewModel.hint)
								.font(.callout)
								.foregroundStyle(.tertiary)
								.padding(.horizontal)
								.opacity(showHint ? 1 : 0)
								.animation(.easeIn, value: viewModel.showHint)
						}
					}
					.frame(minHeight: geometry.size.height)
				}
			}
		}
	}
}

struct QuestionCounter: View {
	let progressTitle: String
	var body: some View {
		HStack {
			Text(progressTitle)
				.monospacedDigit()
				.foregroundColor(.white)
				.padding(.horizontal)
				.padding(.vertical, 5.0)
				.background(RoundedRectangle(cornerRadius: 50.0)
					.fill(Color.paletteBlue)
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
		QuestionView(viewModel: viewModel)
	}
}
