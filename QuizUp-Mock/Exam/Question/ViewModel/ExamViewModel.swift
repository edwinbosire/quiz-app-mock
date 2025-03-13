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
class ExamViewModel: ObservableObject, Identifiable {
	let id: UUID = UUID()
	var examId: Int { exam.examId }
	private let repository: ExamRepository = .shared

	private var refreshTask: Task<Void, Error>?
	@Published var progress: Int = 0 {
		didSet {
			Task { @MainActor in
				progressTitle = "Question \(progress+1) of \(exam.questions.count)"
			}
		}
	}

	@Published var exam: AttemptedExam
	@Published var progressTitle: String = ""
	@Published var examStatus: AttemptedExam.Status
	@Published var bookmarked: Bool = false
	@Published var questions: [QuestionViewModel] = []

	var currentQuestion: QuestionViewModel {
		if progress >= 0 && progress < questions.count {
			return questions[progress]
		} else {
			fatalError("Index out of bounds")
		}
	}

	var correctQuestions: [AttemptedQuestion] {
		availableQuestions.filter { $0.isAnsweredCorrectly }.map { $0.question }
	}

	var incorrectQuestions: [AttemptedQuestion] {
		availableQuestions.filter { !$0.isAnsweredCorrectly }.map { $0.question }
	}

	var resultViewModel: ExamResultViewModel {
		let attemptedExam = AttemptedExam(examId: exam.examId, questions: attemptedQuestions, status: examStatus, dateAttempted: Date.now, duration: exam.duration, selectedChoices: exam.selectedChoices)
		return ExamResultViewModel(exam: attemptedExam)
	}

	var attemptedQuestions: [AttemptedQuestion] {
		self.questions.map { $0.finish() }
	}

	var formattedScore: String {
		exam.scorePercentage > 0.0 ? String(format: "%.0f %%", exam.scorePercentage) : "-"
	}

	var availableQuestions = [QuestionViewModel]()
	@Published var viewState: ViewState = .loading


	init(exam: Exam) {
		self.exam = AttemptedExam(from: exam)
		progress = 0
		examStatus = .started

		if exam.questions.isEmpty {
			fatalError("An exam must have atleast one question")
		}
		self.questions = exam.questions.enumerated().map { i, q in
			let examQuestion = AttemptedQuestion(from: q)
			return QuestionViewModel(question: examQuestion, owner: self, index: i)
		}

		self.progressTitle = "Question \(progress+1) of \(exam.questions.count)"
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
		guard let mockExam = try? await ExamRepository.shared.loadMockExam(with: examId) else {
			return nil
		}

		let viewModel = ExamViewModel(exam: mockExam)
		viewModel.viewState = .content
		return viewModel
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


	func finishExam(duration: TimeInterval = 0.0) {
		let finished = questions.filter { !$0.allAnswersSelected }.count > 0
		self.examStatus = finished ? .finished : .didNotFinish
		exam.update(duration: duration)
//		DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
//			guard let self = self else { return }
////			self.exam.correctQuestions = self.correctQuestions
////			self.exam.incorrectQuestions = self.incorrectQuestions
////			self.exam.userSelectedAnswer = self.userSelectedAnswers
////			self.exam.score = self.score
////			self.exam.status = self.examStatus
//			self.examStatus = .finished
//
//			let solvedQuestions = self.questions.map {
//				AttemptedQuestion(from: $0.question, answerState: $0.answerState)
//			}
//			let attemptedExam = AttemptedExam(
//				questions: solvedQuestions,
//				status: self.examStatus,
//				dateAttempted: Date.now,
//				duration: duration,
//				score: self.score,
//				userSelectedAnswer: self.userSelectedAnswers)
//			Task {
//				do {
//					try await self.repository.save(exam: attemptedExam)
//					try await self.repository.save(result: self.result)
//				} catch {
//					print("Failed to save exam at the end of the quiz")
//				}
//			}
//		}
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
		let question1 = Question(id: "id",
								 sectionId: "History",
								 title: "Which of these is NOT part of the United Kingdom?",
								 hint: "",
								 choices: [
									Choice("Scotland"),
									Choice("Wales"),
									Choice("The Republic of Ireland"),
									Choice("Northern Ireland")])
		let exam = Exam(id: 0, questions: [question1])
		let viewModel = ExamViewModel(exam: exam)
		viewModel.availableQuestions = viewModel.questions
		return viewModel
	}
}
