//
//  MainMenu.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 15/03/2023.
//

import SwiftUI

struct MainMenu: View {
	@ObservedObject var menuViewModel: MenuViewModel
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

						PracticeExamList(menuViewModel: menuViewModel)
					}
				}

				WelcomeBackHeaderView(route: $route)
			}
		}
	}
}

struct MainMenu_Previews: PreviewProvider {
	@Namespace static var namespace
    static var previews: some View {
		NavigationStack {
			MainMenu(menuViewModel: MenuViewModel(repository: .shared), route: .constant(.mainMenu), namespace: namespace)
		}

    }
}

struct WelcomeBackHeaderView: View {
	@Binding var route: Route
	@Environment(\.colorScheme) var colorScheme
	var isDarkMode: Bool { colorScheme == .dark }
	@State private var searchText = ""

	var body: some View {
		VStack {
			VStack(alignment: .leading) {
				HStack {
					Text("Welcome Back")
						.font(.largeTitle)
						.bold()
						.foregroundColor(.paletteBlueSecondary)
					Spacer()

					Button(action: { route = .settings}) {
						Image(systemName: "gear")
							.font(.title3)
							.foregroundColor(Color("primary"))
					}
				}

				Text("British Citizenship Exam Preparation")
					.foregroundStyle(.secondary)

				SearchBar(text: $searchText)
			}
			.padding()
		}
		.background(Color("Background")
		)
		.shadow(color: .black.opacity(0.1), radius: 10, y: 4)

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
							.foregroundColor(Color("primary"))
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
							.foregroundColor(Color("primary"))
						
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
		.navigationDestination(for: String.self) { chapter in
			HanbookMainMenu(chapter: chapter)
		}

	}
}


struct HandbookView: View {
	@Binding var route: Route
	@Environment(\.colorScheme) var colorScheme
	var isDarkMode: Bool { colorScheme == .dark }

	let chapters = [("Chaper 1", "Values and Principles of the UK", 25.0),
					("Chaper 2", "What is the UK?", 15.0),
					("Chaper 3", "A Long and Illustrious History", 0.0),
					("Chaper 4", "A Modern, Thriving Society", 0.0),
					("Chaper 5", "The UK Government, the Law and your Role", 0.0)]

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
				}
				.padding(.horizontal)
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ForEach(chapters.enumerated().map {$0}, id:\.offset) { ndx, chapter in
							NavigationLink(value: "\(chapter.0): \(chapter.1)") {
								handbookCards(ndx, chapter)
									.background(RoundedRectangle(cornerRadius: 10).fill(Color("RowBackground2")).shadow(color: .black.opacity(0.3), radius: 4, y: 2))

							}
						}
						.padding([.bottom, .top])
					}
					.padding(.leading)
				}
			}
			.navigationDestination(for: String.self) { chapter in
				HanbookMainMenu(chapter: chapter)
			}


	}

	fileprivate func handbookCards(_ ndx: Int, _ chapter: (String, String, Double)) -> some View {
		VStack {
			VStack(alignment: .leading) {
				Text(chapter.0)
					.font(.headline)
					.foregroundColor(Color.paletteBlueDark)
					.padding(.top, 20)
				Spacer()
					.frame(height: 0)

				Text(chapter.1)
					.font(.body)
					.padding(.top, 10)
					.foregroundStyle(.secondary)
					.foregroundColor(Color.paletteBlueDark)
					.multilineTextAlignment(.leading)

				Spacer()
					.frame(height: 0)
				Spacer()

				HStack {
					ProgressView("", value: chapter.2, total: 100)
						.padding(.bottom)
						.tint(Color("primary"))

					Spacer()
					Text("\(String(format: "%.0f%%", chapter.2))")
						.foregroundStyle(.tertiary)
						.font(.footnote)
				}
			}
			.padding(.horizontal)
			.frame(width: 150, height: 190)
		}
	}
}

struct PracticeExamList: View {
	@ObservedObject var menuViewModel: MenuViewModel
//	@Binding var route: Route
	@Namespace var namespace

	@Environment(\.colorScheme) var colorScheme
	var isDarkMode: Bool { colorScheme == .dark }

	var body: some View {
		VStack(alignment: .leading) {
			Text("Practice Exams")
				.bold()
				.font(.title2)
				.padding(.leading)
				.padding(.bottom)
				.padding(.top)
				.foregroundColor(.paletteBlueSecondary)


			ZStack {
				Color("RowBackground2")
					.shadow(color: .black.opacity(isDarkMode ? 0.2 : 0.1), radius: 9, x: 0, y: -1)

				LazyVStack {
					ForEach(menuViewModel.exams, id: \.id) { exam in
						NavigationLink(value: exam) {
							VStack {
								HStack {
									Image(systemName: exam.id > 2 ? "lock.slash" : "lock.open")
										.foregroundColor(Color("primary"))
									Text("Mock Exam \(exam.id)")
//										.matchedGeometryEffect(id: "mockTestTitle-\(quiz)", in: namespace)
										.font(.headline)
										.foregroundStyle(.secondary)
										.foregroundColor(Color.paletteBlueDark)
									Spacer()
									Text("76%")
										.font(.body)
										.foregroundColor(exam.id < 2 ? .green : Color("primary"))

								}
								.padding(.leading)
								Divider()
							}
							.padding(.top, 15)
							.contentShape(Rectangle())
							.background(Color("RowBackground2"))
							.padding(.horizontal)
						}
					}
				}
				.background(Color("RowBackground2"))
			}
		}
		.sheet(isPresented:  $menuViewModel.isShowingMonitizationPage, content: {
			MonitizationView(route: $menuViewModel.route)
		})
		.navigationDestination(for: Exam.self) { exam in
			if exam.id < 3 {
				let exam = menuViewModel.examViewModel(with: exam)
				ExamView(viewModel: exam, route: $menuViewModel.route, namespace: namespace)
					.navigationBarBackButtonHidden()

			} else {
				MonitizationView(route: $menuViewModel.route)
					.navigationBarHidden(true)
					.contentTransition(.opacity)
			}
		}
	}
}
