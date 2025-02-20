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
	@EnvironmentObject var router: Router
	@Namespace var namespace

	@State private var selectedPage: Int = 0
	@State private var isShowingMenu: Bool = false
	@State private var promptRestartExam: Bool = false

	var body: some View {
		VStack {
			toolbarContent()
			ExamProgressView(currentPage: $viewModel.progress, pages: viewModel.questions.count)

			HStack(alignment: .firstTextBaseline) {
				QuestionCounter(progressTitle: viewModel.progressTitle)
				Spacer()
				TimerView(viewModel: viewModel)
			}
			.padding(.top)


			TabView(selection: $viewModel.progress) {
				ForEach(viewModel.questions) { question in
					QuestionPageView(viewModel: question)
						.frame(maxWidth: .infinity)
						.frame(maxHeight: .infinity)
						.tag(question.index)
				}
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
			Spacer()
			Spacer()
		}
		.gradientBackground()
		.onAppear {
			selectedPage = viewModel.progress
		}
		.onChange(of: viewModel.progress) { _, newValue in
			selectedPage = newValue
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

	@ViewBuilder func toolbarContent() -> some View {
		HStack {
			Button(action: {}) {
				Text("Mock Test")
					.matchedGeometryEffect(id: "mockTestTitle-0", in: namespace)
					.font(.title3)
					.bold()
			}

			Spacer()

			Button(action: {viewModel.bookmarked.toggle()}) {
				Image(systemName: viewModel.bookmarked ? "bookmark.fill" : "bookmark")
			}
			.foregroundColor(.paletteBlue)

			Button(action: {isShowingMenu.toggle()}) {
				Image(systemName: isShowingMenu ? "ellipsis.circle.fill" : "ellipsis.circle")
			}
			.foregroundColor(.paletteBlue)
		}
		.padding()

	}
}

struct TimerView: View {
	@Environment(\.colorScheme) var colorScheme
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	@ObservedObject var viewModel: ExamViewModel
	@State var timeRemaining = 1*5
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
				// TODO: Work on the DNF screen
				viewModel.finishExam()
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


struct QuestionCounter: View {
	@Environment(\.colorScheme) var colorScheme
	let progressTitle: String
	var isLightappearance: Bool { colorScheme == .light}
	var body: some View {
		HStack {
			Text(progressTitle)
				.font(.subheadline)
				.monospacedDigit()
				.foregroundColor(.secondary)
				.foregroundStyle(.tertiary)
			Spacer()
		}
		.padding(.bottom)
		.padding(.horizontal)

	}
}


#Preview {

	@Previewable @State var isPresented: Bool = false
	@Previewable @Namespace var namespace
	@Previewable @State var viewModel = ExamViewModel.mock()

	QuestionView(viewModel: viewModel)
		.task {
			viewModel = await PreviewModel.mockExamViewModel()
		}
}
