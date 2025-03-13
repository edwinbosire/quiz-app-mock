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
	let questions: [AttemptedQuestion]
	var status: Status
	var dateAttempted: Date
	var duration: TimeInterval
	var selectedChoices: [Choice: AttemptedQuestion.State]

	var correctQuestions: [AttemptedQuestion] {
		questions.filter({ $0.isAnsweredCorrectly })
	}

	var incorrectQuestions: [AttemptedQuestion] {
		questions.filter({ $0.selectedChoices.values.allSatisfy({$0 != .correct}) })
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
		 duration: TimeInterval,
		 selectedChoices: [Choice: AttemptedQuestion.State]) {
		self.id = UUID().uuidString
		self.examId = examId
		self.questions = questions
		self.status = status
		self.dateAttempted = dateAttempted
		self.duration = duration
		self.selectedChoices = selectedChoices
	}

	init(from exam: Exam) {
		self.id = UUID().uuidString
		self.examId = exam.id
		self.questions = exam.questions.map(AttemptedQuestion.init)
		self.status = .attempted
		self.dateAttempted = Date()
		self.duration = 0
		self.selectedChoices = [:]
	}

	mutating func update(date attemptedDate: Date) {
		self.dateAttempted = attemptedDate
	}

	mutating func update(duration: TimeInterval) {
		self.duration = duration
	}

	mutating func update(selectedChoices: [Choice: AttemptedQuestion.State]) {
		self.selectedChoices = selectedChoices
	}
}
