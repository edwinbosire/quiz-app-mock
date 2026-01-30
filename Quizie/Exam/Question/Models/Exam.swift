//
//  ExamModel.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 12/03/2023.
//

import Foundation

struct Exam: Codable, Hashable, Equatable {
	let id: Int
	let questions: [Question]
}

extension Exam {
	static func mock() async -> Exam {
		guard let mock = try? await ExamRepository.shared.loadMockExam(with: 00) else {
			fatalError("Unable to load mock exam")
		}

		return Exam(id: mock.id, questions: mock.questions)
	}
}
