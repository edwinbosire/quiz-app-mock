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
				.foregroundColor(.titleText)


			ZStack {
				Color.clear
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
				.background(.thickMaterial)
			}
		}
		.sheet(isPresented:  $menuViewModel.isShowingMonitizationPage, content: {
			MonitizationView(route: $menuViewModel.route)
		})
		.navigationDestination(for: ExamViewModel.self) { exam in
				ExamView(viewModel: exam, route: $menuViewModel.route, namespace: namespace)
					.navigationBarBackButtonHidden()
		}
		.onAppear {
			menuViewModel.reloadExams()
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
					.foregroundColor(locked ? .gray : .bodyText)
				Text("Mock Exam \(exam.id)")
					.font(.subheadline)
					.foregroundStyle(.primary)
					.foregroundColor(locked ? .gray : .bodyText)
				Spacer()
				Text(exam.formattedScore)
					.font(.body)
					.foregroundColor(locked ? .bodyText : .green)

			}
			.padding(.leading)
			.padding(.bottom, 8)
			Divider()
		}
		.padding(.top, 8)
		.contentShape(Rectangle())
		.padding(.horizontal)
	}
}

struct PracticeExamList_Previews: PreviewProvider {

	struct ContentView: View {
		@Namespace var namespace
		@StateObject private var menuViewModel = MenuViewModel.shared
		var body: some View {
			PracticeExamList(namespace: _namespace)
				.background(Backgrounds())
			.environmentObject(menuViewModel)
		}
	}

	static var previews: some View {
		ContentView()
	}

}
