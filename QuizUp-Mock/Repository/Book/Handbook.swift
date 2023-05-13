//
//  Handbook.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 29/04/2023.
//

import Foundation


struct Handbook: Codable, Hashable {
	let chapters: [Chapter]

	enum CodingKeys: String, CodingKey {
		case chapters = "data"
	}
}

struct Chapter: Codable, Identifiable, Hashable {
	var id: String { title }
	let title : String
	let topics: [Topic]
	var chapterTitle: String { title.replacingOccurrences(of: title, with: "").replacingOccurrences(of: ":", with: "") }

	enum CodingKeys: String, CodingKey {
		case title
		case topics = "content"
	}
}

struct ChaperDestination: Hashable {
	let chapter: Chapter
	let index: Int
}
extension Chapter: Equatable {
	static func == (lhs: Chapter, rhs: Chapter) -> Bool {
		lhs.title == rhs.title
	}
}

struct Topic: Codable, Hashable {
	let title: String
	let content: String
}

extension Topic: Identifiable {
	var id: String { title }
}

//struct SubTopics: Codable {
//	let title: String
//	let content: String
//}
