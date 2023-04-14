//
//  MainMenu.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 15/03/2023.
//

import SwiftUI

struct MainMenu: View {
	@EnvironmentObject private var menuViewModel: MenuViewModel
	@Binding var route: Route
	var namespace: Namespace.ID

	@Environment(\.colorScheme) var colorScheme
	var isDarkMode: Bool { colorScheme == .dark }

	var body: some View {
		NavigationStack {
			ZStack(alignment: .topLeading) {
				Color("Background")
					.opacity(0.9)
					.ignoresSafeArea()

				ScrollView {
					VStack {
						SummaryView(route: $route)

						HandbookView(route: $route)

						PracticeExamList()
					}
				}

				WelcomeBackHeaderView()
			}
		}
	}
}

struct MainMenu_Previews: PreviewProvider {
	struct ContentView: View {
		@Namespace var namespace
		@StateObject private var menuViewModel = MenuViewModel.shared
		var body: some View {
			NavigationStack {
				MainMenu(route: .constant(.mainMenu), namespace: namespace)
			}
			.environmentObject(menuViewModel)
		}
	}

	static var previews: some View {
		ContentView()
    }
}


struct SummaryView: View {
	@Binding var route: Route
	@Environment(\.colorScheme) var colorScheme
	var isDarkMode: Bool { colorScheme == .dark }

	var body: some View {
		VStack {
			Spacer()
				.frame(height: 150)
			HStack {
				Button(action: {route = .progressReport}) {
					VStack {
						Text("75 %")
							.font(.largeTitle)
							.bold()
							.foregroundColor(Color.paletteBlueDark)
						Text("Average score")
							.font(.title3)
							.foregroundStyle(.secondary)
							.foregroundColor(Color.paletteBlueDark)
					}
					.frame(maxWidth: .infinity)
					.frame(height: 150)
					.background(RoundedRectangle(cornerRadius: 10)
						.fill(Color("RowBackground2"))
						.shadow(color: .black.opacity(0.3), radius: 4, y: 2))
				}
				Spacer()
					.frame(width: 20)

				NavigationLink(value: "Main Menu") {
					VStack {
						Text("25 %")
							.font(.largeTitle)
							.bold()
							.foregroundColor(Color.paletteBlueDark)
						
						Text("Reading Progress")
							.font(.title3)
							.foregroundStyle(.secondary)
							.foregroundColor(Color.paletteBlueDark)

					}
					.frame(maxWidth: .infinity)
					.frame(height: 150)
					.background(RoundedRectangle(cornerRadius: 10)
						.fill(Color("RowBackground2"))
						.shadow(color: .black.opacity(0.3), radius: 4, y: 2))
				}
			}
			.padding()
		}
		.padding(.bottom)
		.background(
			Color("Background")
				.clipShape(RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 20))
				.shadow(color: .black.opacity(0.1), radius: 10, x:0.0, y: 15.0)
		)
		.navigationDestination(for: Book.Chapter.self) { chapter in
			HanbookMainMenu(chapter: chapter)
		}

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
						.foregroundColor(.paletteBlueSecondary)

					Spacer()

					Button(action: { route = .handbook(chapter: 0)}) {
						HStack {
							Text("View all")
							Image(systemName: "chevron.right")
						}
						.foregroundColor(Color("primary"))
					}
					.disabled(true)
				}
				.padding(.horizontal)
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ForEach(book.chapters, id:\.title) { chapter in
							NavigationLink(value: chapter) {
								handbookCards(chapter)
									.background(RoundedRectangle(cornerRadius: 10).fill(Color("RowBackground2")).shadow(color: .black.opacity(0.3), radius: 4, y: 2))

							}
						}
						.padding([.bottom, .top])
					}
					.padding(.leading)
				}
			}
			.navigationDestination(for: Book.Chapter.self) { chapter in
				HanbookMainMenu(chapter: chapter)
			}


	}

	fileprivate func handbookCards(_ chapter: Book.Chapter) -> some View {
		VStack {
			VStack(alignment: .leading) {
				Text(chapter.title)
					.font(.headline)
					.foregroundColor(Color.paletteBlueDark)
					.padding(.top, 20)
				Spacer()
					.frame(height: 0)

				Text(chapter.subTitle)
					.font(.body)
					.padding(.top, 10)
					.foregroundStyle(.secondary)
					.foregroundColor(Color.paletteBlueDark)
					.multilineTextAlignment(.leading)

				Spacer()
					.frame(height: 0)
				Spacer()

				HStack {
					ProgressView("", value: chapter.progress, total: 100)
						.padding(.bottom)
						.tint(Color("primary"))

					Spacer()
					Text("\(String(format: "%.0f%%", chapter.progress))")
						.foregroundStyle(.tertiary)
						.font(.footnote)
				}
			}
			.padding(.horizontal)
			.frame(width: 150, height: 190)
		}
	}
}
