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
	var handbook: Handbook = Handbook(chapters: [])

	@discardableResult
	func loadHandbook() async throws -> Handbook {
		self.handbook = try parseJSONData()
		return handbook
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
