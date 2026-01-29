//
//  ExamView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 12/03/2023.
//

import SwiftUI

struct ExamView: View {
	@Environment(Router.self) var router

	@State private var viewModel: ExamViewModel? = nil
	@State private var viewState: ViewState = .loading
	@State var scale = 0.9
	var examId: Int

	init(examId: Int) {
		self.examId = examId
	}

	var body: some View {
		ZStack {
			switch viewState {
				case .content:
					if let viewModel {
						content(viewModel: viewModel)
					} else {
						ExamErrorScreen(retryAction: reload)
					}
				case .loading:
					ExamLoadingView()
						.task { await reload() }
				case .error, .empty:
					ExamErrorScreen(retryAction: reload)
			}
		}
		.task {
			await reload()
		}
	}

	func reload() async {
		viewState = .loading
		if let vm = await ExamViewModel.viewDidLoad(examId) {
			self.viewModel = vm
			viewState = .content
		} else {
			viewState = .error
		}
	}

	@ViewBuilder func content(viewModel: ExamViewModel) -> some View {
		switch viewModel.examStatus {
			case .unattempted, .attempted, .started, .paused:
				QuestionView(viewModel: viewModel)
			case .finished, .didNotFinish:
				ResultsView(result: ExamResultViewModel(exam: viewModel.exam))
		}
	}
}

struct ExamView_Previews: PreviewProvider {
	@Namespace static var namespace
	static var previews: some View {
		ExamView(examId: 00)
	}
}
