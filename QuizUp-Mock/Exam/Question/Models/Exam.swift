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

	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id &&
		lhs.questions == rhs.questions
	}
}

extension Exam {
	static func mock() -> Exam {
		ExamRepository.mockExam(questions: 5)
	}
}
