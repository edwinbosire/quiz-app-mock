//
//  HanbookMainMenu.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct HanbookMainMenu: View {
	let book: Book = Book()
	var body: some View {
		List {
			Section("Chapter 1: The values and principles of the UK") {
				ForEach(chapter1, id: \.self) { title in
					NavigationLink {
						HandbookReader(chapter: book.chapters[0])
					} label: {
						BookChapterRow(title: title)
					}
					.listRowBackground(Color.defaultBackground)
				}
			}

			Section("Chapter 2: What is the UK") {
				NavigationLink {
					HandbookReader(chapter: book.chapters[1])
				} label: {
					BookChapterRow(title: "2.1 What is the UK")
				}
				.listRowBackground(Color.defaultBackground)

			}

			Section("Chapter 3: A long and illustrious history") {
				ForEach(chapter3, id: \.self) { title in
					NavigationLink {
						HandbookReader(chapter: book.chapters[2])
					} label: {
						BookChapterRow(title: title)
					}
				}
				.listRowBackground(Color.defaultBackground)

			}

			Section("Chapter 4: A mordern, thriving society") {
				ForEach(chapter4, id: \.self) { title in
					NavigationLink {
						HandbookReader(chapter: book.chapters[3])
					} label: {
						BookChapterRow(title: title)
					}
				}
				.listRowBackground(Color.defaultBackground)
			}

			Section("Chapter 5: The UK government, the law and your role") {
				ForEach(chapter5, id: \.self) { title in
					NavigationLink {
						HandbookReader(chapter: book.chapters[4])
					} label: {
						BookChapterRow(title: title)
					}
				}
				.listRowBackground(Color.defaultBackground)
			}

			Section("Key materials and facts") {
				BookChapterRow(title: "Key materials and facts")
					.listRowBackground(Color.defaultBackground)

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
	// TODO: Move these items to data models.
	let chapter1 = [
		"1.1 The values and priciples of the UK",
		"1.2 Becoming a permanent resident",
		"1.3 Taking the Life in the UK test"
	]

	let chapter3 = [
		"3.1 Early Britain",
		"3.2 The Middle Ages",
		"3.3 The Tudors and Stuarts",
		"3.4 A Global Power",
		"3.5 The 20th Century",
		"3.6 Britain Since 1945"
		]

	let chapter4 = [
		"4.1 The UK Today",
		"4.2 Religion",
		"4.3 Customs and Traditions",
		"4.4 Sport",
		"4.5 Arts and Culture",
		"4.6 Leisure",
		"4.7 Places of Interest"]

	let chapter5 = [
		"5.1 The Development of British Democracy",
		"5.2 The British Constitution",
		"5.3 The Government",
		"5.4 The UK and International Institutions",
		"5.5 Respecting the Law",
		"5.6 The Role of the Courts",
		"5.7 Fundamental Principles",
		"5.8 Taxation",
		"5.9 Driving",
		"5.10 Your Role in the Community",
		"5.11 How you can Support your Community",
		"5.12 Looking After the Environment"
	]


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
