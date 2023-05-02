//
//  HandbookView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 15/04/2023.
//

import SwiftUI

struct HandbookView: View {
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.featureFlags) var featureFlags
	var isDarkMode: Bool { colorScheme == .dark }
	var handbookViewModel: HandbookViewModel

	var body: some View {
		VStack(alignment: .leading, spacing: 10.0) {
				HStack(alignment: .firstTextBaseline) {
					Text("Handbook")
						.bold()
						.font(.title2)
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

				}
				.padding(.horizontal)
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ForEach(Array(handbookViewModel.chapters.enumerated()), id: \.offset) { ndx, chapter in
							NavigationLink(value: chapter) {
								handbookCards(chapter, index: ndx+1)
							}
							.background(.thinMaterial)
							.cornerRadius(10)

						}
						.padding([.bottom, .top])
					}
					.padding(.leading)
				}
			}
			.navigationDestination(for: Chapter.self) { chapter in
				HandbookReader(chapter: chapter)
			}
	}

	fileprivate func handbookCards(_ chapter: Chapter, index: Int) -> some View {
		VStack {
			let title = "Chapter \(index)"
			VStack(alignment: .leading) {
				Text(title)
					.font(.headline)
					.foregroundColor(.titleText)
					.padding(.top, 20)
				Spacer()
					.frame(height: 0)

				Text(chapter.title.replacingOccurrences(of: title, with: "").replacingOccurrences(of: ": ", with: ""))
					.font(.subheadline)
					.padding(.top, 10)
					.foregroundStyle(.secondary)
					.foregroundColor(.subTitleText)
					.multilineTextAlignment(.leading)

				Spacer()
					.frame(height: 0)
				Spacer()

				if featureFlags.progressTrackingEnabled {
					HStack {
						ProgressView("", value: 10, total: 100)
							.padding(.bottom)
							.tint(.accentColor)

						Spacer()
						Text("\(String(format: "%.0f%%", 10))")
							.foregroundColor(.accentColor)
							.font(.footnote)
					}
				}
			}
			.padding(.horizontal)
			.frame(width: 150, height: 150)
		}
	}
}

struct HandbookView_Previews: PreviewProvider {
    static var previews: some View {
		HandbookView(handbookViewModel: HandbookViewModel())
			.background(Backgrounds())
    }
}
