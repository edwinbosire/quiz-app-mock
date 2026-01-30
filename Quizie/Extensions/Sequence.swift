//
//  Sequence.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 30/01/2025.
//

import Foundation

extension Sequence {
	func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
		var values = [T]()

		for element in self {
			try await values.append(transform(element))
		}

		return values
	}
}
