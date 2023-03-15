//
//  ExamModel.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 12/03/2023.
//

import Foundation

enum ExamStatus {
	case attempted
	case unattempted
	case started
	case paused
	case didNotFinish
	case finished
}

struct Exam {
	let questions: [Question]
	let status: ExamStatus
	var score: Int = 0
	var correctQuestions: [Question] = []
	var incorrectQuestions: [Question] = []
}

extension Exam {
	static func mock() -> Exam {
		let questionBank = QuestionDTO.loadAllQuestions()!
		let exam = Array(questionBank[0..<5])
		return Exam(questions: exam, status: .unattempted)
	}
}
