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
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("Handbook")
			.toolbarColorScheme(.dark, for: .navigationBar)
			.toolbarBackground(PastelTheme.background, for: .navigationBar)
			.toolbarBackground(.visible, for: .navigationBar)

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
			ForEach(Array(chapters.enumerated()), id: \.offset) { ndx, chapter in
				ChapterSection(title: chapter.title)
				ForEach(Array(chapter.topics.enumerated()), id: \.offset) { paragraph, topic in
					BookChapterRow(title: topic.title, chapter: ndx, paragraph: paragraph)
				}
			}
			.listRowInsets(EdgeInsets())
			.listRowBackground(Color.clear)
			.listRowSeparator(.hidden)

		}
		.searchable(text: $queryString, placement: .navigationBarDrawer(displayMode: .automatic))
		.listStyle(.inset)
		.scrollContentBackground(.hidden)
		.background {
			Rectangle()
				.fill(PastelTheme.background)
				.ignoresSafeArea()
		}
	}
}

private struct BookChapterRow: View {
	@Environment(Router.self) var router
	@State private var readingProgress: Double = .zero
	let title: String
	let chapter: Int
	let paragraph: Int

	var body: some View {
		HStack {
			TopicProgressView(value: readingProgress/100)
				.frame(width: 20)
			Text("\(chapter+1).\(paragraph+1) \(title)")
				.font(.body)
				.foregroundStyle(PastelTheme.bodyText)
			Spacer()
			Image(systemName: "chevron.right")
				.font(.caption)
				.fontWeight(.light)
				.foregroundStyle(PastelTheme.bodyText)

		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: CornerRadius)
				.fill(PastelTheme.rowBackground.darken)
				.shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
				.overlay {
					RoundedRectangle(cornerRadius: CornerRadius)
						.fill(PastelTheme.rowBackground)
						.offset(y: -2.0)
				}
				.clipShape(RoundedRectangle(cornerRadius: CornerRadius))

		)
		.padding(.leading, 24.0)
		.padding(.trailing)
		.padding(.bottom, 4)
		.onTapGesture {
			router.navigate(to: .handbookChapter(chapter))
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

// Chapter Section Component
struct ChapterSection: View {
	let title: String

	var body: some View {
		HStack {
			Text(title)
				.font(.title3)
				.fontWeight(.semibold)
				.foregroundColor(.titleText)
			Spacer()
		}
		.padding()
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(.bottom, 2.0)
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
