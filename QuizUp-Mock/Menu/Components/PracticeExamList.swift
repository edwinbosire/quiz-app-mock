//
//  PracticeExamList.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 14/04/2023.
//

import SwiftUI

struct PracticeExamList: View {
	@EnvironmentObject private var menuViewModel: MenuViewModel
	@Environment(\.featureFlags) var featureFlags
	@EnvironmentObject var router: Router
	@Namespace var namespace

	@Environment(\.colorScheme) var colorScheme
	var isDarkMode: Bool { colorScheme == .dark }
	@State private var freeUserAllowance: Int = 3

	var body: some View {
		VStack(alignment: .leading) {
			Title()

			ForEach(menuViewModel.exams) { exam in
				PracticeExamListRow(viewModel: exam, locked: exam.id > freeUserAllowance)
			}
		}
		.padding()
		.background {
			LinearGradient(colors: [
				Color.blue.opacity(0.1),
				Color.blue.opacity(0.5),
				Color.defaultBackground,
				Color.defaultBackground,
				Color.blue.opacity(0.5)], startPoint: .top, endPoint: .bottom)
				.blur(radius: 75)
				.ignoresSafeArea()
		}
//		.background(.ultraThinMaterial)
		.task {
			await menuViewModel.reloadExams()
			freeUserAllowance = featureFlags.freeUserExamAllowance
		}
		.onChange(of: featureFlags.freeUserExamAllowance) { _, newValue in
			freeUserAllowance = newValue
		}
	}

	@ViewBuilder
	func Title() -> some View {
		Text("Start Practising")
			.bold()
			.font(.title2)
			.foregroundColor(.titleText)
	}
}

struct PracticeExamListRow: View {
	@EnvironmentObject var router: Router

	let viewModel: ExamViewModel
	let locked: Bool
	var body: some View {
		HStack {
			Image(systemName: locked ? "lock.slash" : "lock.open")
				.font(.caption)
				.foregroundColor(locked ? .gray : .secondary)
			Text("Mock Exam \(viewModel.id)")
				.font(.headline)
				.fontWeight(.medium)
				.foregroundStyle(.primary)
				.foregroundColor(locked ? .gray : .primary)
			Spacer()
			Text(viewModel.formattedScore)
				.font(.body)
				.foregroundStyle(.secondary)
				.foregroundColor(Color.secondary)
				.opacity(locked ? 0.0 : 1)

		}
		.padding()
//		.background(.background.opacity(0.8))
		.background {
			RoundedRectangle(cornerRadius: 10)
				.fill(Color("Background"))
				.shadow(color: .black.opacity(0.09), radius: 4, y: 2)
		}
//		.shadow(color: .red.opacity(0.15), radius: 3, x: 0, y: 3)
		.contentShape(Rectangle())
		.onTapGesture {
			if locked {
				router.navigate(to: .monetization, navigationType: .sheet)
			} else {
				router.navigate(to: .mockTest(viewModel.id), navigationType: .fullScreenCover)
			}
		}
	}
}

struct PracticeExamList_Previews: PreviewProvider {

	struct ContentView: View {
		@Namespace var namespace
		@StateObject private var menuViewModel = MenuViewModel.shared
		var body: some View {
			ScrollView {
				PracticeExamList(namespace: _namespace)
					.background(Backgrounds())
					.environmentObject(menuViewModel)
			}
		}
	}

	static var previews: some View {
		ContentView()
	}

}
