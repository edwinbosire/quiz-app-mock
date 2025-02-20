//
//  ExamView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 12/03/2023.
//

import SwiftUI

struct ExamView: View {
	var examId: Int
	@State private var viewModel: ExamViewModel? = nil
	@State private var viewState: ViewState = .loading
	@EnvironmentObject var router: Router
	//	var namespace: Namespace.ID
	@State var scale = 0.9

	init (examId: Int) {
		self.examId = examId
	}

	var body: some View {
		switch viewState {
			case .content:
				content(viewModel: viewModel!)
			case .loading:
				loadingView()
			case .error:
				Text("Error")
					.background(GradientColors.bluPurpl.getGradient())
					.frame(maxWidth: .infinity, maxHeight: .infinity)

		}

	}

	@ViewBuilder func loadingView() -> some View {
		VStack {
			ProgressView()
			Text("Loading...")
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.task {
			if let vm = await ExamViewModel.viewDidLoad(examId) {
				self.viewModel = vm
				self.viewState = .content
			} else {
				self.viewState = .error
			}
		}

	}
	@ViewBuilder func content(viewModel: ExamViewModel) -> some View {
		switch viewModel.examStatus {
			case .unattempted:
				QuestionView(viewModel: viewModel)
			case .finished:
				ResultsView(result: viewModel.result)
			case .attempted:
				Text("Exam was attempted")
			case .started:
				Text("Exam was started")
			case .paused:
				Text("Exam Paused")
			case .didNotFinish:
				ResultsView(result: viewModel.result)
		}
	}
}

struct ExamView_Previews: PreviewProvider {
	@Namespace static var namespace
	static var previews: some View {
		ExamView(examId: 00)
	}
}
