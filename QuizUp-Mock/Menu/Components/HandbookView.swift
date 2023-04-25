//
//  HandbookView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 15/04/2023.
//

import SwiftUI

struct HandbookView: View {
	@Binding var route: Route
	@Environment(\.colorScheme) var colorScheme
	var isDarkMode: Bool { colorScheme == .dark }
	@State var book: Book = Book()

	var body: some View {
			VStack(alignment: .leading) {
				HStack(alignment: .firstTextBaseline) {
					Text("Handbook")
						.bold()
						.font(.title2)
						.padding(.bottom, -10)
						.padding(.top, 40)
						.foregroundColor(.titleText)

					Spacer()
					NavigationLink {
						HanbookMainMenu()
					} label: {
						HStack {
							Text("View all")
							Image(systemName: "chevron.right")
						}
						.foregroundColor(.titleText)
						.foregroundStyle(.tertiary)

					}

//					NavigationLink(value: Book().chapters[0]) {
//					}
				}
				.padding(.horizontal)
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ForEach(book.chapters, id:\.title) { chapter in
							NavigationLink(value: chapter) {
								handbookCards(chapter)
//									.background(RoundedRectangle(cornerRadius: 10)
////										.fill(Color.rowBackground)
//
//										.shadow(color: .black.opacity(0.09), radius: 4, y: 2))
							}
							.background(.thinMaterial)
							.cornerRadius(10)

						}
						.padding([.bottom, .top])
					}
					.padding(.leading)
				}
			}
			.navigationDestination(for: Book.Chapter.self) { chapter in
				HandbookReader(chapter: chapter)
			}


	}

	fileprivate func handbookCards(_ chapter: Book.Chapter) -> some View {
		VStack {
			VStack(alignment: .leading) {
				Text(chapter.title)
					.font(.headline)
					.foregroundColor(.titleText)
					.padding(.top, 20)
				Spacer()
					.frame(height: 0)

				Text(chapter.subTitle)
					.font(.subheadline)
					.padding(.top, 10)
					.foregroundStyle(.secondary)
					.foregroundColor(.subTitleText)
					.multilineTextAlignment(.leading)

				Spacer()
					.frame(height: 0)
				Spacer()

				HStack {
					ProgressView("", value: chapter.progress, total: 100)
						.padding(.bottom)
						.tint(.accentColor)

					Spacer()
					Text("\(String(format: "%.0f%%", chapter.progress))")
						.foregroundColor(.accentColor)
						.font(.footnote)
				}
			}
			.padding(.horizontal)
			.frame(width: 150, height: 190)
		}
	}
}
struct HandbookView_Previews: PreviewProvider {
    static var previews: some View {
		HandbookView(route: .constant(.handbook(chapter: 1)))
			.background(Backgrounds())
    }
}


struct Book {
	struct Chapter: Hashable {
		let title: String
		let subTitle: String
		let resource: String
		var progress: Double = 0.0

	}

	static let resources:[(String, String, String)] = {
		[
			("Chaper 1", "Values and Principles of the UK", "chapter_1"),
			("Chaper 2", "What is the UK?", "chapter_2"),
			("Chaper 3", "A Long and Illustrious History", "chapter_3"),
			("Chaper 4", "A Modern, Thriving Society", "chapter_4"),
			("Chaper 5", "The UK Government, the Law and your Role", "chapter_5")
		]
	}()

	var chapters: [Chapter] = {
		Self.resources.compactMap { (chaper, title, fileName) in
			if let htmlFile = Bundle.main.path(forResource: fileName, ofType: "html"),
			   let html = try? String(contentsOfFile: htmlFile, encoding: String.Encoding.utf8) {
				return Chapter(title: chaper, subTitle: title, resource: html, progress: 10.0)
			}
			return nil
		}
	}()
}
