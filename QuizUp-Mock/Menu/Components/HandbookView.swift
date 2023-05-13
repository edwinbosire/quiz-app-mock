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
	@Binding  var route: NavigationPath

	var body: some View {
		VStack(alignment: .leading, spacing: 10.0) {
				HStack(alignment: .firstTextBaseline) {
					Text("Handbook")
						.bold()
						.font(.title2)
						.foregroundColor(.titleText)

					Spacer()

						HStack {
							Text("View all")
							Image(systemName: "chevron.right")
						}
						.foregroundColor(.titleText)
						.foregroundStyle(.tertiary)
						.containerShape(Rectangle())
						.onTapGesture {
							if let vm = handbookViewModel.handbook {
								route.append(vm)
							}
						}


				}
				.padding(.horizontal)
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ForEach(Array(handbookViewModel.chapters.enumerated()), id: \.offset) { ndx, chapter in
							NavigationLink(value: ChaperDestination(chapter: chapter, index: ndx)) {
								HandbookCards(chapter: chapter, index: ndx+1)
							}
							.gradientBackground()
							.background(.thinMaterial)
							.cornerRadius(10)

						}
						.padding([.bottom, .top])
					}
					.padding(.leading)
				}
			}
	}
}

struct HandbookCards: View {
	@Environment(\.featureFlags) var featureFlags
	var chapter: Chapter
	var index: Int
	@State private var chapterProgress: Double = .zero

	var body: some View {
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
						ProgressView("", value: chapterProgress, total: 100)
							.padding(.bottom)
							.tint(.purple.opacity(0.4))

						Spacer()
						Text("\(String(format: "%.0f%%", chapterProgress))")
							.foregroundColor(.purple.opacity(0.4))
							.font(.footnote)
					}
				}
			}
			.padding(.horizontal)
			.frame(width: 150, height: 150)
			.onAppear {
				var totalProgress = 0.0
				for topic in chapter.topics {
					let topicProgress = UserDefaults.standard.double(forKey: topic.title)
					totalProgress += topicProgress / Double(chapter.topics.count)
				}
				chapterProgress = totalProgress
			}
		}

	}
}
struct HandbookView_Previews: PreviewProvider {
    static var previews: some View {
		@State var route = NavigationPath()
		HandbookView(handbookViewModel: HandbookViewModel(), route: $route)
			.background(Backgrounds())
    }
}
