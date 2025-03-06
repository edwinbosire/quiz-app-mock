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
			Image(systemName: "lock.slash")
				.font(.caption)
				.foregroundColor(PastelTheme.subTitle)
				.opacity(locked ? 1 : 0)
			Text("Mock Exam \(viewModel.id)")
				.font(.body)
				.fontWeight(.medium)
				.foregroundStyle(PastelTheme.bodyText)
				.foregroundColor(locked ? PastelTheme.subTitle : PastelTheme.bodyText)
			Spacer()
			Text(viewModel.formattedScore)
				.font(.body)
				.foregroundStyle(.secondary)
				.foregroundColor(Color.secondary)
				.opacity(locked ? 0.0 : 1)
			Image(systemName: "chevron.right")
				.font(.caption)
				.fontWeight(.light)
				.foregroundStyle(PastelTheme.bodyText)


		}
		.padding()
		.background {
			RoundedRectangle(cornerRadius: CornerRadius)
				.fill(PastelTheme.rowBackground.darken)
				.shadow(color: .black.opacity(0.09), radius: 4, y: 2)
				.overlay {
					RoundedRectangle(cornerRadius: CornerRadius)
						.fill(PastelTheme.rowBackground.lighten)
						.offset(y: -2)
				}
				.clipShape(RoundedRectangle(cornerRadius: CornerRadius))
		}
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
