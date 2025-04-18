//
//  ProgressReportDetailView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 09/03/2025.
//

import SwiftUI

struct ProgressReportDetailView: View {
	let result: ExamResultViewModel
	@Environment(\.dismiss) var dismiss

	var body: some View {
		ScrollView {
			ForEach(result.questionsViewModels) { question in
				ResultsRow(viewModel: question)
			}
		}
		.background(PastelTheme.background.gradient)
		.navigationBarBackButtonHidden(true)
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
				Button {
					dismiss()
				} label: {
					HStack {
						Image(systemName: "chevron.backward")
						Text("Back")
					}
					.bold()
					.foregroundStyle(PastelTheme.title)
				}
			}
		}
	}
}

#Preview {

	var _result: ExamResultViewModel?
	var result: ExamResultViewModel {
		get {
			if let _result {
				return _result
			}

			let exam = Exam(id: 00, questions: [])
			let mockExam = AttemptedExam(from: exam)
			return ExamResultViewModel(exam: mockExam)
		}
		set {
			_result = newValue
		}
	}

	ProgressReportDetailView(result: result)
		.task {
			let exam = await Exam.mock()
			var mockExam = AttemptedExam(from: exam)

			let answer = exam.questions[0].choices.filter(\Choice.isAnswer).first!
			mockExam.questions[0].updateSelectedChoices([answer: .correct])

			let answer2 = exam.questions[1].choices.filter(\Choice.isAnswer).first!
			mockExam.questions[1].updateSelected(answer, state: .correct)

			result = ExamResultViewModel(exam: mockExam)
		}
}
