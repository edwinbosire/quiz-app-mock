//
//  ExamResultViewModel.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 11/03/2025.
//

import Foundation

@MainActor
struct ExamResultViewModel: Codable, Hashable, Equatable, Identifiable {
	let id: String
	let examId: Int
	var exam: AttemptedExam

	lazy var status: AttemptedExam.Status = {
		exam.status
	}()

	lazy var userSelectedAnswer: [Choice: AttemptedQuestion.State] = {
		exam.selectedChoices
	}()

	var date: Date {
		exam.dateAttempted
	}

	var prompt: String {
		if exam.scorePercentage >= 75 {
			return "Congratulation! You've passed the test"
		} else {
			return "Your score is below the 75% pass mark"
		}
	}

	var formattedScore: String {
		exam.scorePercentage > 0.0 ? String(format: "%.0f %%", exam.scorePercentage) : "-"
	}

	var scorePercentage: Double {
		exam.scorePercentage
	}

	var correctQuestions: [AttemptedQuestion] {
		exam.correctQuestions
	}

	var incorrectQuestions: [AttemptedQuestion] {
		exam.incorrectQuestions
	}
	
	var formattedDate: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		dateFormatter.locale = Locale.current
		return dateFormatter.string(from: self.date)
	}


	lazy var chartDate: String = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		dateFormatter.locale = Locale.current
		dateFormatter.setLocalizedDateFormatFromTemplate("MMMd")

		return dateFormatter.string(from: self.date)
	}()

	init(id: String = UUID().uuidString, exam: AttemptedExam) {
		self.id = id
		self.examId = exam.examId
		self.exam = exam
	}
}
