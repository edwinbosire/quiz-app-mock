//
//  HanbookMainMenu.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct HandbookMainMenu: View {
	let bookViewModel = HandbookViewModel.shared
	let selectedChapter: Int = 0
	@State private var queryString = ""
	@State var chapters: [Chapter] = []

	init(selectedChapter: Int = 0, queryString: String = "") {
		self.queryString = queryString
	}

	var body: some View {
		HandbookMainMenuList(chapters: chapters, queryString: $queryString)
			.gradientBackground()
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("Handbook")
			.onChange(of: queryString) {_, newValue in
				if newValue.isEmpty {
					chapters = bookViewModel.chapters
				} else {
					chapters = searchChapters(with: newValue)
				}
			}
			.onAppear {
				chapters = bookViewModel.chapters
			}
	}

	private func searchChapters(with query: String) -> [Chapter] {
		 bookViewModel
			.chapters
			.filter {
				$0.title.localizedCaseInsensitiveContains(query) ||
				$0.topics.filter {
					$0.title.localizedCaseInsensitiveContains(query)
				}.count > 0
			}
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
		.padding(.top, 1)
		.searchable(text: $queryString, placement: .navigationBarDrawer(displayMode: .automatic))
		.listStyle(.insetGrouped)
		.scrollContentBackground(.hidden)
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
			HandbookMainMenu()
		}
    }
}


class HandbookViewModel: ObservableObject {
	static let shared = HandbookViewModel()

	let repository = HandbookRepository()

	@Published var handbook: Handbook = .empty

	lazy var chapters: [Chapter] = {
		handbook.chapters
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

	init() {
		Task {
			if let handbook = try? await repository.loadHandbook() {
				self.handbook = handbook
			}
		}
	}

	func load(chapter: Chapter) async -> Chapter? {
		return chapters.first(where: { $0 == chapter} )
	}

}
