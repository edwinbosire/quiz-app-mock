//
//  ExamView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 12/03/2023.
//

import SwiftUI

struct ExamView: View {
	@ObservedObject var viewModel: ExamViewModel
	@Binding var route: Route
	var namespace: Namespace.ID
	@State var scale = 0.9

    var body: some View {
		Group {
			switch viewModel.examStatus {
				case .unattempted:
					 QuestionView(viewModel: viewModel,route: $route, namespace: namespace)
				case .finished:
					ResultsView(viewModel: viewModel, route: $route)
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
		.navigationBarBackButtonHidden()

    }
}

struct ExamView_Previews: PreviewProvider {
	@Namespace static var namespace
    static var previews: some View {
		let examViewModel = ExamViewModel.mock()
		ExamView(viewModel: examViewModel, route: .constant(.mockTest(testId: 0)), namespace: namespace)
    }
}
