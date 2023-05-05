//
//  HanbookMainMenu.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct HanbookMainMenu: View {
	let bookViewModel = HandbookViewModel.shared
	@State private var queryString = ""

	init(queryString: String = "") {
		self.queryString = queryString
	}

	var body: some View {
			List {
				ForEach(filteredChapters) { chapter in
					Section(chapter.title) {
						ForEach(chapter.topics) { topic in
							NavigationLink {
								HandbookReader(chapter: chapter)
							} label: {
								BookChapterRow(title: topic.title)
							}
						}
						.listRowBackground(Color.defaultBackground)
					}
				}
			}
			.listStyle(.insetGrouped)
			.scrollContentBackground(.hidden)
			.frame(maxHeight: .infinity)
			.searchable(text: $queryString)
			.navigationTitle("Handbook")
			.gradientBackground()
	}

	private var filteredChapters: [Chapter] {
		guard !queryString.isEmpty else {
			return bookViewModel.chapters
		}

		return bookViewModel.chapters.filter { $0.title.localizedCaseInsensitiveContains(queryString) || $0.topics.filter { $0.title.localizedCaseInsensitiveContains(queryString)}.count > 0 }
	}

}

private struct BookChapterRow: View {
	let title: String
	var body: some View {
		HStack() {
			Text(title)
				.font(.subheadline)
		}
	}
}
struct HanbookMainMenu_Previews: PreviewProvider {
    static var previews: some View {
		NavigationStack {
			HanbookMainMenu()
		}
    }
}


class HandbookViewModel {
	static let shared = HandbookViewModel()

	let repository = HandbookRepository()

	var handbook: Handbook? {
		repository.handbook
	}

	lazy var chapters: [Chapter] = {
		repository.loadChapters()
	}()
}
