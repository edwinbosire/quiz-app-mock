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
	@State var chapters: [Chapter] = []

	init(queryString: String = "") {
		self.queryString = queryString
	}

	var body: some View {
		HandbookMainMenuList(chapters: chapters, queryString: $queryString)
			.gradientBackground()
			.onAppear {
				chapters = bookViewModel.chapters
			}
			.onChange(of: queryString) { search in
				guard !search.isEmpty else {
					chapters = bookViewModel.chapters
					return
				}

				chapters = bookViewModel.chapters.filter { $0.title.localizedCaseInsensitiveContains(search) || $0.topics.filter { $0.title.localizedCaseInsensitiveContains(search)}.count > 0 }

			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("Handbook")

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
