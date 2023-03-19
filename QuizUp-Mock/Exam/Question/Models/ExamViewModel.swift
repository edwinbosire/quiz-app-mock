//
//  ExamViewModel.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 12/03/2023.
//

import Foundation

protocol QuestionOwner {
	func progressToNextQuestions()
	func allowProgressToNextQuestion()
}


class ExamViewModel: ObservableObject {
	private let exam: Exam
	private let questionsCount: Int
	@Published var progress: Int {
		didSet {
			progressTitle = "Question \(progress+1) of \(questionsCount)"
		}
	}
	@Published var progressTitle: String
	@Published var examStatus: ExamStatus
	@Published var bookmarked: Bool = false
	lazy var questions: [QuestionViewModel] = {
		exam.questions.enumerated().map { i,q in QuestionViewModel(question: q, index: i, owner: self) }
	}()

	var score: Int {
		var result = 0
		for question in availableQuestions {
			var questionWeight = 0
			for answer in question.selectedAnswers {

				if answer.isAnswer {
					questionWeight += 1
				}
			}
			if questionWeight == question.selectedAnswers.count {
				result += 1
			}
			questionWeight = 0
		}
		return result
	}

	var scorePercentage: Double {
		(Double(score) / Double(availableQuestions.count) * 100)
	}

	var prompt: String {
		if scorePercentage >= 75 {
			return "Congratulation! You've passed the test"
		} else {
			return "Your score is below the 74% pass mark"
		}
	}
	@Published var availableQuestions = [QuestionViewModel]()

	init(exam: Exam) {
		self.exam = exam
		progress = 0
		questionsCount = exam.questions.count
		progressTitle = ""
		examStatus = exam.status
		prepareExam()
	}

	private func prepareExam() {
		if let first = questions.first {
			availableQuestions.append(first)
			progress = availableQuestions.count - 1
		}
	}

	func restartExam() {
		for q in questions {
			q.reset()
		}
		availableQuestions = [QuestionViewModel]()
		progress = 0
		progressTitle = ""
		examStatus = .unattempted
		prepareExam()
	}

}

extension ExamViewModel: QuestionOwner {
	func progressToNextQuestions() {
		print("progress to next question")
		if progress < questions.count-1 {
			let next = progress + 1
			availableQuestions.append(questions[next])
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
				self?.progress += 1
			}
		} else {
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
				self?.examStatus = .finished
			}
		}
	}

	func allowProgressToNextQuestion() {
		print("got the answer wrong, stay on the same page, but allow scrolling to next question")
		if progress < questions.count-1 {
			let next = progress + 1
			availableQuestions.append(questions[next])
		} else {
			examStatus = .finished
		}

	}


}

extension ExamViewModel {
	static func mock() -> ExamViewModel {
		let exam = Exam.mock()
		let viewModel = ExamViewModel(exam: exam)
		viewModel.availableQuestions = viewModel.questions
		return viewModel
	}
}
