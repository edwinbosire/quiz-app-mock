//
//  QuestionView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 10/03/2023.
//

import SwiftUI

struct QuestionView: View {
	@Environment(\.dismiss) var dismiss

	@ObservedObject var viewModel: ExamViewModel
	@EnvironmentObject var router: Router
	@Namespace var namespace

//	@State private var selectedPage: Int = 0
	@State private var isShowingMenu: Bool = false
	@State private var promptRestartExam: Bool = false

	var body: some View {
		VStack {
			ToolBarContentView(viewModel: viewModel, isShowingMenu: $isShowingMenu)
			ExamProgressView(currentPage: $viewModel.progress, questions: viewModel.questions)

			HStack(alignment: .firstTextBaseline) {
				QuestionCounter(progressTitle: viewModel.progressTitle)
				Spacer()
				TimerView(viewModel: viewModel)
			}
			.padding(.top)


			TabView(selection: $viewModel.progress) {
				ForEach(viewModel.questions) { question in
					QuestionPageView(viewModel: question)
						.tag(question.index)
				}
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
			.animation(.easeOut(duration: 0.2), value: viewModel.progress)
		}
		.gradientBackground()
		.actionSheet(isPresented: $isShowingMenu) {
			ActionSheet(title: Text(""),
						message: nil,
						buttons: [
							.default(Text("Report Issue")),
							.default(Text("Restart Test")){ promptRestartExam.toggle() },
							.destructive(Text("Quit Test")) { router.dismiss() },
							.cancel()
						])
		}
		.alert("Restart Exam?", isPresented: $promptRestartExam, actions: {
			Button("Cancel", role: .cancel, action: {})
			Button("Restart", role: .destructive, action: { restartExam()})
		}, message: {
			Text("You will lose all progress")
		})
		.onChange(of: viewModel.examStatus) { oldValue, newValue in
			if newValue == .finished {
				router.navigate(to: .resultsView(viewModel.result), navigationType: .fullScreenCover)
			}
		}
	}

	func restartExam() {
		_ = viewModel.restartExam()
	}
}

private struct ToolBarContentView: View {
	@Environment(\.colorScheme) var colorScheme
	@ObservedObject var viewModel: ExamViewModel
	@Binding var isShowingMenu: Bool

	var body: some View {
		HStack {
			Button(action: { isShowingMenu.toggle() }) {
				Text("Mock Test")
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
	@Environment(\.featureFlags) var featureFlags

	@ObservedObject var viewModel: ExamViewModel

	@State private var timer: Timer? = nil
	@State var timeRemaining = 1*1*60

	var body: some View {
		HStack {
			Image(systemName: "clock")
				.foregroundStyle(.tertiary)
				.font(.subheadline)

			Text("\(timeString(timeRemaining))")
				.font(.subheadline)
				.monospacedDigit()
				.padding(.trailing)
				.foregroundStyle(.tertiary)
				.shadow(color: colorScheme == .dark ? .clear : Color.white.opacity(0.5), radius: 1, x: 2, y: 1)
		}
		.background(.clear)
		.onAppear {
			timeRemaining = featureFlags.examDuration*60
			startTimer()
		}

	}

	// MARK: - Timer Functionality
	func startTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
			if timeRemaining > 0 {
				timeRemaining -= 1
			} else {
				timer?.invalidate()
				Task {@MainActor in
					viewModel.finishExam()
				}
			}
		}
	}

	func timeString(_ time: Int) -> String {
		let minutes = time / 60
		let seconds = time % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}
}

struct ExamProgressView: View {
	@Environment(\.colorScheme) var colorScheme
	@Binding var currentPage: Int
	var questions: [QuestionViewModel]

	var body: some View {
		GeometryReader { reader in
			let width = reader.size.width/CGFloat(questions.count)
			HStack(spacing: 0) {
				ForEach(0..<questions.count, id:\.self) { i in
					Rectangle()
						.fill(getProgressColor(for: i))
						.frame(width: width)
						.border(colorScheme == .light ? .gray.opacity(0.1) : .white.opacity(0.07))
						.animation(.easeIn, value: currentPage)
				}
			}

		}
		.frame(height: 5)
	}

	func getProgressColor(for index: Int) -> Color {
		if index == currentPage {
			return Color.paletteBlueSecondary.opacity(0.5)
		} else if questions[index].isAnswered {
			return  questions[index].isAnsweredCorrectly ? Color.green : .red
		} else {
			return Color.paletteBlue.opacity(0.1)
		}
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
