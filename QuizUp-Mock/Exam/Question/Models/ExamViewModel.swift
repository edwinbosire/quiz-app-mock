//
//  ExamViewModel.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 12/03/2023.
//

import Foundation
import SwiftUI

protocol QuestionOwner {
	func progressToNextQuestions() async
	func allowProgressToNextQuestion() async
}

@MainActor
class ExamViewModel: ObservableObject {
	var exam: Exam
	private let repository: ExamRepository = .shared
	private var questionsCount: Int {
		exam.questions.count
	}

	private var refreshTask: Task<Void, Error>?
	@Published var progress: Int {
		didSet {
			Task { @MainActor in
				progressTitle = "Question \(progress+1) of \(questionsCount)"
			}
		}
	}
	@Published var progressTitle: String
	@Published var examStatus: ExamStatus
	@Published var bookmarked: Bool = false
	@Published var questions: [QuestionViewModel] = []

	var correctQuestions: [Question] {
		availableQuestions.filter { $0.isAnsweredCorrectly }.map { $0.question }
	}

	var incorrectQuestions: [Question] {
		availableQuestions.filter { !$0.isAnsweredCorrectly }.map { $0.question }
	}

	// Each question has an array of possible selected answers
	var userSelectedAnswers: [String: [Choice]] {
		availableQuestions.reduce([String: [Choice]]()) { (dict, question) -> [String: [Choice]] in
			var dict = dict
			dict[question.question.id] = Array(question.selectedChoices)
			return dict
		}
	}

	var score: Int {
		var result = 0
		for question in availableQuestions {
			var questionWeight = 0
			for answer in question.selectedChoices {

				if answer.isAnswer {
					questionWeight += 1
				}
			}
			if questionWeight == question.selectedChoices.count {
				result += 1
			}
			questionWeight = 0
		}
		return result
	}

	var scorePercentage: Double {
		(Double(score) / Double(availableQuestions.count) * 100)
	}

	var formattedScore: String {
		if exam.status == .unattempted {
			return  ""
		} else {
			return score>0 ? String(format: "%.0f %%", (Double(exam.correctQuestions.count)/Double(questions.count) * 100)) : "-"
		}
	}

	var prompt: String {
		if scorePercentage >= 75 {
			return "Congratulation! You've passed the test"
		} else {
			return "Your score is below the 74% pass mark"
		}
	}

	var result: ExamResult {
		ExamResult(
			examId: exam.id,
			questions: exam.questions,
			status: examStatus,
			correctQuestions: correctQuestions,
			incorrectQuestions: incorrectQuestions,
			userSelectedAnswer: userSelectedAnswers
		)
	}

	var availableQuestions = [QuestionViewModel]()
	@Published var viewState: ViewState = .loading


	init(exam: Exam) {
		self.exam = exam
		progress = 0
		progressTitle = ""
		examStatus = exam.status

		self.questions = exam.questions.enumerated().map { i, q in
			QuestionViewModel(question: q, index: i, owner: self)
		}
	}

	convenience init?(examId: Int) async {
		guard let exam = try? await ExamRepository.shared.loadExam(with: examId) else {
			return nil
		}
		self.init(exam: exam)
	}

	func restartExam() -> ExamViewModel{
		for q in questions {
			q.reset()
		}
		availableQuestions = [QuestionViewModel]()
		progress = 0
		progressTitle = ""
		examStatus = .unattempted

		return self
	}

	static func viewDidLoad(_ examId: Int) async -> ExamViewModel? {
		if let viewModel = await ExamViewModel(examId: examId) {
			viewModel.viewState = .content
			return viewModel
		} else {
			return nil
		}

	}
}

extension ExamViewModel: QuestionOwner {
	func progressToNextQuestions() {
		print("progress to next question")
		if progress+1 < questions.count {
			let next = progress + 1
			availableQuestions.append(questions[next])
			refreshTask?.cancel()
			refreshTask = Task {
				try await Task.sleep(until: .now + .seconds(1.0), clock: .continuous)
				Task{ @MainActor in
					withAnimation {
						self.progress += 1
					}
				}
			}
		} else {
			finishExam()
		}
	}
	
	func allowProgressToNextQuestion() {
		print("got the answer wrong, stay on the same page, but allow scrolling to next question")
		if progress < questions.count-1 {
			let next = progress + 1
			availableQuestions.append(questions[next])
		} else {
			finishExam()
		}
	}


	func finishExam() {
		let finished = questions.filter { !$0.allAnswersSelected }.count > 0
		self.examStatus = finished ? .finished : .didNotFinish

		DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
			guard let self = self else {return}
			self.exam.correctQuestions = self.correctQuestions
			self.exam.incorrectQuestions = self.incorrectQuestions
			self.exam.userSelectedAnswer = self.userSelectedAnswers
			self.exam.score = self.score
			self.exam.status = self.examStatus
			self.examStatus = .finished
			Task {
				do {
					try await self.repository.save(exam: self.exam)
					try await self.repository.save(result: self.result)
				} catch {
					print("Failed to save exam at the end of the quiz")
				}
			}
		}
	}
}

extension ExamViewModel: @preconcurrency Identifiable {
	var id: Int {
		exam.id
	}
}

extension ExamViewModel: @preconcurrency Hashable {
	static func == (lhs: ExamViewModel, rhs: ExamViewModel) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

extension ExamViewModel {
	static func mock() -> ExamViewModel {
//		let exam = Task {
//			 await Exam.mock()
//		}.value
		let exam = Exam(id: 00, questions: [], status: .unattempted)
		let viewModel = ExamViewModel(exam: exam)
		viewModel.availableQuestions = viewModel.questions
		return viewModel
	}
}
