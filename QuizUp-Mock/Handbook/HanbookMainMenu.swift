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
		HandbookMainMenuList(chapters: filteredChapters, queryString: $queryString)
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

struct HandbookMainMenuList: View {
	var chapters: [Chapter]
	@Binding var queryString: String
	var body: some View {
		List {
			ForEach(chapters) { chapter in
				Section(chapter.title) {
					ForEach(Array(chapter.topics.enumerated()), id: \.offset) { ndx, topic in
						NavigationLink {
							HandbookReader(chapter: chapter, index: ndx)
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
//		.gradientBackground()
	}
}
private struct BookChapterRow: View {
	let title: String
	@State private var readingProgress: Double = .zero
	var body: some View {
		HStack() {
			TopicProgressView(value: readingProgress/100)
				.frame(width: 20)
				.padding(.vertical, 4)
			Text(title)
				.font(.subheadline)
		}
		.onAppear {
			readingProgress = UserDefaults.standard.double(forKey: title)
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

	var totalProgress: Double {
		var totalProgress = 0.0
		for chapter in chapters {
			for topic in chapter.topics {
				let topicProgress = UserDefaults.standard.double(forKey: topic.title)
				totalProgress += topicProgress / Double(chapter.topics.count)
			}
		}
		return totalProgress / Double(chapters.count)
	}
}
