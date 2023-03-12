//
//  ExamView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 12/03/2023.
//

import SwiftUI

struct ExamView: View {
	@ObservedObject var viewModel: ExamViewModel
    var body: some View {
		Group {
			switch viewModel.examStatus {
				case .unattempted:
					 QuestionView(viewModel: viewModel)
				case .finished:
					ResultsView(viewModel: viewModel)
				case .attempted:
					 Text("Exam was attempted")
				case .started:
					 Text("Exam was started")
				case .paused:
					 Text("Exam Paused")
				case .didNotFinish:
					 Text("Exam was not finished")
			}
		}
    }
}

struct ResultsView: View {
	@ObservedObject var viewModel: ExamViewModel
	var body: some View {
		VStack {
			Text("Congratulations this mock exam")
			Text("Your score is: \(viewModel.scorePercentage)")
		}
	}
}

struct ResultsView_Previews: PreviewProvider {
	static var previews: some View {
		let examViewModel = ExamViewModel.mock()
		ResultsView(viewModel: examViewModel)
	}
}

struct ExamView_Previews: PreviewProvider {
    static var previews: some View {
		let examViewModel = ExamViewModel.mock()
        ExamView(viewModel: examViewModel)
    }
}
