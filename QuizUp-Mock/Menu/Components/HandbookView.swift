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
	@Environment(Router.self) var router

	var handbookViewModel: HandbookViewModel

	var body: some View {
		VStack(alignment: .leading, spacing: 0.0) {
			SectionHeaderView()
				.containerShape(Rectangle())
				.onTapGesture {
					router.navigate(to: .handbook)
				}

			HandbookChapters()
		}
	}

	@ViewBuilder
	func SectionHeaderView() -> some View {
		HStack(alignment: .firstTextBaseline) {
			Text("Read the Study Book")
				.bold()
				.font(.title2)
				.foregroundColor(.titleText)

			Spacer()

			Image(systemName: "arrowshape.right.circle.fill")
				.font(.title)
				.foregroundColor(.titleText)
				.foregroundStyle(PastelTheme.title)

		}
		.padding()
	}

	@ViewBuilder
	func HandbookChapters() -> some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack {
				ForEach(Array(handbookViewModel.chapters.enumerated()), id: \.offset) { ndx, chapter in
					HandbookCards(chapter: chapter, index: ndx)
				}
			}
			.scrollTargetLayout()
			.padding([.leading, .bottom])
		}
		.scrollTargetBehavior(.viewAligned)
	}
}

struct HandbookCards: View {
	@Environment(\.featureFlags) var featureFlags
	@Environment(Router.self) var router

	var chapter: Chapter
	var index: Int
	let stripeHeight = 15.0
	@State private var chapterProgress: Double = .zero

	var title: String {
		"Chapter \(index+1)"
	}

	var chapterTitle: String {
		chapter.chapterTitle
	}

	var headerColor: Color {
		switch index {
			case 0: return PastelTheme.blue
			case 1: return PastelTheme.green
			case 2: return PastelTheme.yellow
			case 3: return PastelTheme.orange
			case 4: return PastelTheme.deepOrange
			default:
				return .red
		}
	}
	var body: some View {

		VStack(alignment: .leading, spacing: 0.0) {
				Text(title)
					.font(.title2)
					.fontWeight(.heavy)
					.foregroundColor(PastelTheme.title)
					.lineLimit(1)
					.padding()
					.padding(.top)
					.frame(maxWidth: .infinity, alignment: .leading)
					.background(headerColor)

			VStack(alignment: .leading) {
				Text(chapterTitle)
					.font(.headline)
					.fontWeight(.medium)
					.foregroundStyle(PastelTheme.bodyText)
					.multilineTextAlignment(.leading)
					.lineLimit(2)
			}
			.padding()
			.frame(height: 80.0)
			.frame(maxWidth: .infinity, alignment: .leading)

			ProgressIndicator()
		}
		.pastelThemeBackground(PastelTheme.rowBackground)
		.frame(width: 200)
		.onAppear {
			if featureFlags.progressTrackingEnabled {
				var totalProgress = 0.0
				for topic in chapter.topics {
					let topicProgress = UserDefaults.standard.double(forKey: topic.title)
					totalProgress += topicProgress / Double(chapter.topics.count)
				}
				chapterProgress = 0.4//totalProgress
			}
		}
		.onTapGesture {
			router.navigate(to: .handbookChapter(index))
		}

	}

	@ViewBuilder
	func ProgressIndicator() -> some View {
		HStack {
			ProgressView(value: chapterProgress, total: 100)
				.tint(PastelTheme.subTitle)
				.background(PastelTheme.navBackground.darken)
				.clipShape(Capsule())

		}
		.padding(.bottom)
		.padding(.horizontal)
		.opacity(featureFlags.progressTrackingEnabled ? 1.0 : 0.0)
	}
}

#Preview {
	HandbookView(handbookViewModel: HandbookViewModel())
		.background(PastelTheme.background)
}
