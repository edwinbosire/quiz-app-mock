//
//  PracticeExamList.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 14/04/2023.
//

import SwiftUI

struct PracticeExamList: View {
	@EnvironmentObject private var menuViewModel: MenuViewModel
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
					.defaultShadow()

				LazyVStack {
					ForEach(menuViewModel.exams) { exam in
						if exam.id < 3 {
							NavigationLink(value: exam) {
								PracticeExamListRow(exam: exam, locked: false)
							}
						} else {
							PracticeExamListRow(exam: exam, locked: true)
								.contentShape(Rectangle())
								.onTapGesture {
									menuViewModel.isShowingMonitizationPage.toggle()
								}
						}
					}
				}
				.background(Color("RowBackground2"))
			}
		}
		.sheet(isPresented:  $menuViewModel.isShowingMonitizationPage, content: {
			MonitizationView(route: $menuViewModel.route)
		})
		.navigationDestination(for: ExamViewModel.self) { exam in
				ExamView(viewModel: exam, route: $menuViewModel.route, namespace: namespace)
					.navigationBarBackButtonHidden()
		}
	}
}

struct PracticeExamListRow: View {
	let exam: ExamViewModel
	let locked: Bool
	var body: some View {
		VStack {
			HStack {
				Image(systemName: locked ? "lock.slash" : "lock.open")
					.foregroundColor(Color("primary"))
				Text("Mock Exam \(exam.id)")
					.font(.headline)
					.foregroundStyle(.secondary)
					.foregroundColor(Color.paletteBlueDark)
				Spacer()
				Text(exam.formattedScore)
					.font(.body)
					.foregroundColor(locked ? Color("primary") : .green)

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

struct PracticeExamList_Previews: PreviewProvider {

	struct ContentView: View {
		@Namespace var namespace
		@StateObject private var menuViewModel = MenuViewModel.shared
		var body: some View {
			PracticeExamList(namespace: _namespace)
			.environmentObject(menuViewModel)
		}
	}

	static var previews: some View {
		ContentView()
	}

}
