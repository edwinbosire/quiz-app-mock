//
//  HanbookMainMenu.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct HanbookMainMenu: View {
	let bookViewModel = HandbookViewModel()

	var body: some View {
		List {
			ForEach(bookViewModel.chapters) { chapter in
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
		.background(gradientBackground)
		.scrollContentBackground(.hidden)
		.frame(maxHeight: .infinity)
		.navigationTitle("Life in the UK Handbook")
	}

	private var gradientBackground: some View {
		LinearGradient(colors: [Color.blue.opacity(0.5), Color.defaultBackground,Color.defaultBackground, Color.blue.opacity(0.5)], startPoint: .top, endPoint: .bottom)
			.blur(radius: 75)
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
		HanbookMainMenu()
    }
}


class HandbookViewModel {
	let repository = HandbookRepository()

	var handbook: Handbook? {
		repository.handbook
	}

	lazy var chapters: [Chapter] = {
		repository.loadChapters()
	}()
}
