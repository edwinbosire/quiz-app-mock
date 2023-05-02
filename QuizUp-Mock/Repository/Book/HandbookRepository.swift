//
//  HandbookRepository.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 29/04/2023.
//

import Foundation

enum HanbookError: Error {
	case unableToLoadHandbookJSONFile
	case unableToDecodeJSONFile
}

class HandbookRepository {
	var handbook: Handbook?

	init() {
		Task {
			do {
				self.handbook = try await loadHandbook()
			} catch {
				print("Failed to initialise handbook: Error: \(error)")
			}
		}
	}

	func loadHandbook() async throws -> Handbook {
		try parseJSONData()
	}

	func loadChapters() -> [Chapter] {
		handbook?.chapters ?? []
	}

	func load(chapter: Chapter) async -> Chapter? {
		guard let handbook = self.handbook else {
			print("could not find chapter \(chapter)")
			return nil
		}

		return handbook.chapters.first(where: { $0 == chapter} )
	}

	func parseJSONData() throws -> Handbook {
		guard let handbookJSONURL = Bundle.main.url(forResource: "handbook", withExtension: "json") else {
			throw HanbookError.unableToLoadHandbookJSONFile
		}

		do {
			let handbookJSON = try Data(contentsOf: handbookJSONURL, options: .alwaysMapped)
			let handbook = try JSONDecoder().decode(Handbook.self, from: handbookJSON)
			return handbook
		} catch {
			print("Error decoding JSON data: \(error.localizedDescription)")
			throw HanbookError.unableToDecodeJSONFile
		}
	}

}
