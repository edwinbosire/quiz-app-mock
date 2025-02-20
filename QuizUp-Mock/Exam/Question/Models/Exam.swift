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
	@DecodableDefault.EmptyList var incorrectQuestions: [Question] = []
	@DecodableDefault.EmptyMap var userSelectedAnswer: [String: [Choice]] = [:]

	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id &&
		lhs.questions == rhs.questions
	}
}

extension Exam {
	static func mock() async -> Exam {
		guard let mock = try? await ExamRepository.shared.loadExam(with: 00) else {
			fatalError("Unable to load mock exam")
		}

		return Exam(id: mock.id, questions: mock.questions, status: .unattempted)
	}
}

@MainActor
struct ExamResult: Codable, Hashable, Equatable, Identifiable {
	let id: UUID
	let examId: Int
	let questions: [Question]
	let status: ExamStatus
	let correctQuestions: [Question]
	let incorrectQuestions: [Question]
	let userSelectedAnswer: [String: [Choice]]

	let date: Date
	let score: Double
	let scorePercentage: Double
	let prompt: String

	var formattedScore: String {
		return scorePercentage > 0.0 ? String(format: "%.0f %%", scorePercentage) : "-"
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

		let score = Double(correctQuestions.count) / Double(questions.count)
		self.score = score.isFinite ? score : .zero
		self.scorePercentage = min(max(score * 100.0, 0.0), 100.0)
		if scorePercentage >= 75 {
			self.prompt = "Congratulation! You've passed the test"
		} else {
			self.prompt = "Your score is below the 75% pass mark"
		}

	}

	init(examId: Int, questions: [Question], status: ExamStatus, correctQuestions: [Question], incorrectQuestions: [Question], userSelectedAnswer: [String : [Choice]]) {
		self.id = UUID()
		self.examId = examId
		self.questions = questions
		self.status = status
		self.correctQuestions = correctQuestions
		self.incorrectQuestions = incorrectQuestions
		self.userSelectedAnswer = userSelectedAnswer
		self.date = Date.now

		let score = Double(correctQuestions.count) / Double(questions.count)
		self.score = score.isFinite ? score : .zero
		self.scorePercentage = min(max(score * 100.0, 0.0), 100.0)

		if scorePercentage >= 75 {
			self.prompt = "Congratulation! You've passed the test"
		} else {
			self.prompt = "Your score is below the 75% pass mark"
		}
	}
}

enum DecodableDefault {}

protocol DecodableDefaultSource {
	associatedtype Value: Decodable
	static var defaultValue: Value { get }
}

extension DecodableDefault {
	@propertyWrapper
	struct Wrapper<Source: DecodableDefaultSource> {
		typealias Value = Source.Value
		var wrappedValue = Source.defaultValue
	}
}

extension DecodableDefault.Wrapper: Decodable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		wrappedValue = try container.decode(Value.self)
	}
}

extension KeyedDecodingContainer {
	func decode<T>(_ type: DecodableDefault.Wrapper<T>.Type,
				   forKey key: Key) throws -> DecodableDefault.Wrapper<T> {
		try decodeIfPresent(type, forKey: key) ?? .init()
	}
}

extension DecodableDefault {
	typealias Source = DecodableDefaultSource
	typealias List = Decodable & ExpressibleByArrayLiteral
	typealias Map = Decodable & ExpressibleByDictionaryLiteral

	enum Sources {
		enum True: Source {
			static var defaultValue: Bool { true }
		}

		enum False: Source {
			static var defaultValue: Bool { false }
		}

		enum EmptyString: Source {
			static var defaultValue: String { "" }
		}

		enum EmptyList<T: List>: Source {
			static var defaultValue: T { [] }
		}

		enum EmptyMap<T: Map>: Source {
			static var defaultValue: T { [:] }
		}
	}
}

extension DecodableDefault {
	typealias True = Wrapper<Sources.True>
	typealias False = Wrapper<Sources.False>
	typealias EmptyString = Wrapper<Sources.EmptyString>
	typealias EmptyList<T: List> = Wrapper<Sources.EmptyList<T>>
	typealias EmptyMap<T: Map> = Wrapper<Sources.EmptyMap<T>>
}

extension DecodableDefault.Wrapper: Equatable where Value: Equatable {}
extension DecodableDefault.Wrapper: Hashable where Value: Hashable {}

extension DecodableDefault.Wrapper: Encodable where Value: Encodable {
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(wrappedValue)
	}
}
