//
//  ExamModel.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 12/03/2023.
//

import Foundation

enum ExamStatus: Codable, Equatable {
	case attempted
	case unattempted
	case started
	case paused
	case didNotFinish
	case finished
}

struct Exam: Codable, Hashable, Equatable {
	let id: Int
	let questions: [Question]
	var status: ExamStatus
	var score: Int = 0
	var correctQuestions: [Question] = []
	var incorrectQuestions: [Question] = []
	var userSelectedAnswer: [String: [Answer]]?

	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id &&
		lhs.questions == rhs.questions
	}
}

extension Exam {
	static func mock() -> Exam {
		return Exam(id: 00, questions: [], status: .unattempted)
	}
}

struct ExamResult: Codable, Hashable, Equatable, Identifiable {
	let id: UUID
	let examId: Int
	let questions: [Question]
	var status: ExamStatus
	var correctQuestions: [Question] = []
	var incorrectQuestions: [Question] = []
	var userSelectedAnswer: [String: [Answer]]?
	var date: Date
	var score: Double {
		Double(correctQuestions.count) / Double(questions.count)
	}

	var scorePercentage: Double {
		score * 100
	}

	var prompt: String {
		if scorePercentage >= 75 {
			return "Congratulation! You've passed the test"
		} else {
			return "Your score is below the 75% pass mark"
		}
	}

	var formattedScore: String {
		if status == .unattempted {
			return  ""
		} else {
			return scorePercentage > 0.0 ? String(format: "%.0f %%", scorePercentage) : "-"
		}
	}

	var formattedDate: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		dateFormatter.locale = Locale.current

		return dateFormatter.string(from: self.date)
	}

	var chartDate: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		dateFormatter.locale = Locale.current
		dateFormatter.setLocalizedDateFormatFromTemplate("MMMd")

		return dateFormatter.string(from: self.date)
	}


	init(exam: Exam) {
		self.id = UUID()
		self.examId = exam.id
		self.questions = exam.questions
		self.status = exam.status
		self.correctQuestions = exam.correctQuestions
		self.incorrectQuestions = exam.incorrectQuestions
		self.userSelectedAnswer = exam.userSelectedAnswer
		self.date = Date.now
	}
}
