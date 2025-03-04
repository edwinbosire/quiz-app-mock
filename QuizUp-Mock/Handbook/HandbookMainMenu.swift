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
		//			.background {
		//				LinearGradient(colors: [
		//					Color.blue.opacity(0.1),
		//					Color.blue.opacity(0.5),
		//					Color.defaultBackground,
		//					Color.defaultBackground,
		//					Color.blue.opacity(0.5)], startPoint: .top, endPoint: .bottom)
		//				.blur(radius: 75)
		//				.ignoresSafeArea()
		//			}
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
			ForEach(Array(chapters.enumerated()), id: \.offset) { ndx, chapter in
				ChapterSection(title: chapter.title)
				ForEach(Array(chapter.topics.enumerated()), id: \.offset) { paragraph, topic in
					BookChapterRow(title: topic.title, chapter: ndx+1, paragraph: paragraph+1)
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
				.fill(GradientColors.bluPurpl.getGradient())
				.ignoresSafeArea()
		}
	}
}

private struct BookChapterRow: View {
	@EnvironmentObject var router: Router
	@State private var readingProgress: Double = .zero
	let title: String
	let chapter: Int
	let paragraph: Int

	var body: some View {
		HStack {
			TopicProgressView(value: readingProgress/100)
				.frame(width: 20)
				.padding(.vertical, 4)
			Text("\(chapter).\(paragraph) \(title)")
				.font(.body)
			Spacer()
			Image(systemName: "chevron.right")
				.font(.caption)
				.fontWeight(.light)
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 10)
				.fill(Color.defaultBackground)
				.shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
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

// Topic Row Component
struct TopicRow: View {
	let title: String
	let isCompleted: Bool
	let color: Color

	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 12)
				.fill(Color.white)
				.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

			HStack(spacing: 16) {
				ZStack {
					Circle()
						.fill(color)
						.frame(width: 40, height: 40)

					Image(systemName: "checkmark")
						.font(.system(size: 20, weight: .bold))
						.foregroundColor(.white)
				}

				Text(title)
					.font(.system(size: 16, weight: .medium))

				Spacer()
			}
			.padding()
		}
		.frame(height: 70)
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
