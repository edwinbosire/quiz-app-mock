//
//  AttemptedExam.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 11/03/2025.
//

import Foundation

struct AttemptedExam: Codable, Hashable {

	enum Status: Codable, Equatable {
		case attempted
		case unattempted
		case started
		case paused
		case didNotFinish
		case finished
	}

	let id: String
	let examId: Int
	var questions: [AttemptedQuestion]
	var status: Status
	var dateAttempted: Date
	var duration: TimeInterval

	var correctQuestions: [AttemptedQuestion] {
		questions.filter({ $0.isFullyAnswered && $0.isAnsweredCorrectly })
	}

	var incorrectQuestions: [AttemptedQuestion] {
		questions.filter({ $0.selectedChoices.values.allSatisfy({$0 != .correct}) })
	}

	var unansweredQuestions: [AttemptedQuestion] {
		questions.filter({ !$0.isFullyAnswered })
	}

	var score: Double {
		let score_ = Double(correctQuestions.count) / Double(questions.count)
		return score_.isFinite ? score_ : .zero
	}

	var scorePercentage: Double {
		min(max(score * 100.0, 0.0), 100.0)
	}

	init(examId: Int,
		 questions: [AttemptedQuestion],
		 status: Status,
		 dateAttempted: Date,
		 duration: TimeInterval) {
		self.id = UUID().uuidString
		self.examId = examId
		self.questions = questions
		self.status = status
		self.dateAttempted = dateAttempted
		self.duration = duration
	}

	init(from exam: Exam) {
		self.id = UUID().uuidString
		self.examId = exam.id
		self.questions = exam.questions.map(AttemptedQuestion.init)
		self.status = .attempted
		self.dateAttempted = Date()
		self.duration = 0
	}

	mutating func update(status: Status) {
		self.status = status
	}
	
	mutating func update(date attemptedDate: Date) {
		self.dateAttempted = attemptedDate
	}

	mutating func update(duration: TimeInterval) {
		self.duration = duration
	}

	mutating func finish(duration: TimeInterval) {
		self.duration = duration
		self.dateAttempted = Date.now
		self.status = .finished
	}
}
