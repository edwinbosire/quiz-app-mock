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
	@EnvironmentObject var router: Router

	var isDarkMode: Bool { colorScheme == .dark }
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

			HStack {
				Text("View all")
				Image(systemName: "chevron.right")
			}
			.foregroundColor(.titleText)
			.foregroundStyle(.tertiary)
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
	@EnvironmentObject var router: Router

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
			case 0: return .blue
			case 1: return .green
			case 2: return .yellow
			case 3: return .orange
			case 4: return .pink
			default:
				return .red
		}
	}
	var body: some View {

		VStack(alignment: .leading, spacing: 0.0) {
			Text(title)
				.font(.title2)
				.fontWeight(.heavy)
				.foregroundColor(.white)
				.lineLimit(1)
				.padding(.top, -stripeHeight*3)

			Text(chapterTitle)
				.font(.subheadline)
				.foregroundStyle(.primary)
				.foregroundColor(.primary)
				.multilineTextAlignment(.leading)
				.lineLimit(2)
				.layoutPriority(1.0)

			Spacer()

			ProgressIndicator()
				.padding(.bottom, 0.0)
		}
		.padding([.horizontal])
		.padding(.top, stripeHeight*5)
		.background {
			ZStack(alignment: .top) {
				Rectangle()
					.fill(.background)
					.opacity(0.3)
				Rectangle()
					.frame(maxHeight: stripeHeight*4.5)
			}
			.foregroundColor(headerColor)
			.background(.thinMaterial)

		}
		.clipShape(RoundedRectangle(cornerRadius: stripeHeight, style: .continuous))
		.frame(width: 200, height: 200)
		.shadow(color: .black.opacity(0.09), radius: 4, x:0.0, y: 2)
		.onAppear {
			if featureFlags.progressTrackingEnabled {
				var totalProgress = 0.0
				for topic in chapter.topics {
					let topicProgress = UserDefaults.standard.double(forKey: topic.title)
					totalProgress += topicProgress / Double(chapter.topics.count)
				}
				chapterProgress = totalProgress
			}
		}
		.onTapGesture {
			router.navigate(to: .handbookChapter(index))
		}

	}

	@ViewBuilder
	func ProgressIndicator() -> some View {
		HStack {
			ProgressView("", value: chapterProgress, total: 100)
				.padding(.bottom)
				.tint(.purple)
				.foregroundStyle(.secondary)

			Spacer()
			Text("\(String(format: "%.0f%%", chapterProgress))")
				.foregroundStyle(.secondary)
				.foregroundColor(.purple)
				.font(.footnote)
		}
		.opacity(featureFlags.progressTrackingEnabled ? 1.0 : 0.0)
	}
}

struct HandbookView_Previews: PreviewProvider {
	static var previews: some View {
		@State var route = NavigationPath()
		VStack {
			HandbookView(handbookViewModel: HandbookViewModel())
				.gradientBackground()
		}
	}
}
