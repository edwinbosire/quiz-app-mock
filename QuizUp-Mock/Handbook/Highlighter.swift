

import Foundation
import WebKit

// Model for storing highlights
struct TextHighlight: Codable, Identifiable {
	var id: String = UUID().uuidString
	var chapterId: String
	var highlightId: String
	var text: String
	var startOffset: Int
	var endOffset: Int
	var color: String
	var timestamp: Date
}

// ViewModel to manage highlights
class HighlightManager: ObservableObject {
	@Published var highlights: [TextHighlight] = []
	private let saveKey = "savedHighlights"

	init() {
		loadHighlights()
	}

	func addHighlight(_ highlight: TextHighlight) {
		highlights.append(highlight)
		saveHighlights()
	}

	func removeHighlight(id: String) {
		highlights.removeAll { $0.highlightId == id }
		saveHighlights()
	}

	func getHighlightsForChapter(chapterId: String) -> [TextHighlight] {
		return highlights.filter { $0.chapterId == chapterId }
	}

	private func saveHighlights() {
		if let encoded = try? JSONEncoder().encode(highlights) {
			UserDefaults.standard.set(encoded, forKey: saveKey)
		}
	}

	private func loadHighlights() {
		if let savedHighlights = UserDefaults.standard.data(forKey: saveKey),
		   let decodedHighlights = try? JSONDecoder().decode([TextHighlight].self, from: savedHighlights) {
			highlights = decodedHighlights
		}
	}
}
