//
//  HandbookReader.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 25/04/2023.
//

import SwiftUI

struct HandbookReader: View {
	@Environment(\.featureFlags) var featureFlags
	@AppStorage("ReaderFontSize") var fontSize: Double = 14
//	@State private var readerFont: Double = 100
	let chapter: Chapter
	let index: Int
	@State private var selection = 0

	var body: some View {
		GeometryReader { proxy in
			TabView(selection: $selection) {
				ForEach(Array(chapter.topics.enumerated()), id: \.offset) { ndx, topic in
					HandbookTopicReader(topic: topic, fontSize: $fontSize).tag(ndx)
				}
			}
			.ignoresSafeArea(.all, edges: .bottom)

		}
		.tabViewStyle(.page(indexDisplayMode: .never))
		.navigationBarTitle(
			Text(chapter.title.components(separatedBy: ":").first ?? ""),
			displayMode: .inline)
		.navigationBarItems(trailing: HStack {
			Button(action: {fontSize += 5}) {
				Image(systemName: "textformat.size.larger")
			}

			Button(action: {fontSize -= 5}) {
				Image(systemName: "textformat.size.smaller")
			}

			Divider()

			Menu {
				ForEach(Array(chapter.topics.enumerated()), id: \.offset) { ndx, topic in
					Button(action: {
						withAnimation {
							selection = ndx
						}
					}) {
						Text(topic.title).tag(ndx)
					}
				}
			} label: {
				Label(title: {Text("Chapters")}, icon:{ Image(systemName: "checklist.unchecked")})
			}
		})
		.background(PastelTheme.background)
		.toolbarColorScheme(.dark, for: .navigationBar)
		.toolbarBackground(
			PastelTheme.background,
			for: .navigationBar)
		.toolbarBackground(.visible, for: .navigationBar)
		.onAppear {
			selection = index
			fontSize = featureFlags.fontSize
		}
		.onChange(of: fontSize) { _, newValue in
			featureFlags.fontSize = newValue
		}

	}
}

struct  HandbookTopicReader: View {
	var topic: Topic
	@Binding var fontSize: Double
	@State var scrollProgress: Double = .zero
	@StateObject private var highlightManager = HighlightManager()

	var body: some View {
			ZStack(alignment: .leading) {
				let title = "<H1>\(topic.title) </H1>"
				HTMLView(html: "\(title) \(topic.content)", chapterId: topic.id, fontSize: $fontSize, scrollProgress: $scrollProgress, highlightManager: highlightManager)
					.frame(maxWidth: .infinity ,maxHeight: .infinity)
					.edgesIgnoringSafeArea(.bottom)

			}
			.onChange(of: scrollProgress) { _, newValue in
				if UserDefaults.standard.double(forKey: topic.title) < newValue {
					UserDefaults.standard.set(newValue, forKey: topic.title)
				}
			}
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					NavigationLink(destination: HighlightsListView(highlightManager: highlightManager, currentChapterId: topic.id)) {
						Image(systemName: "highlighter")
					}
				}
			}

	}
}

// View to display all highlights
struct HighlightsListView: View {
	@ObservedObject var highlightManager: HighlightManager
	let currentChapterId: String
	@State private var filter: HighlightFilter = .all

	enum HighlightFilter {
		case all
		case currentChapter
	}

	var filteredHighlights: [TextHighlight] {
		switch filter {
		case .all:
			return highlightManager.highlights.sorted { $0.timestamp > $1.timestamp }
		case .currentChapter:
			return highlightManager.highlights
				.filter { $0.chapterId == currentChapterId }
				.sorted { $0.timestamp > $1.timestamp }
		}
	}

	var body: some View {
		List {
			Picker("Filter", selection: $filter) {
				Text("All Highlights").tag(HighlightFilter.all)
				Text("Current Chapter").tag(HighlightFilter.currentChapter)
			}
			.pickerStyle(SegmentedPickerStyle())
			.padding(.vertical, 8)

			if filteredHighlights.isEmpty {
				Text("No highlights found")
					.foregroundColor(.secondary)
					.frame(maxWidth: .infinity, alignment: .center)
					.padding()
			} else {
				ForEach(filteredHighlights) { highlight in
					HighlightItemView(highlight: highlight)
				}
			}
		}
		.listStyle(InsetGroupedListStyle())
		.navigationTitle("Highlights")
	}
}

struct HighlightItemView: View {
	let highlight: TextHighlight

	var chapterTitle: String {
		switch highlight.chapterId {
			case "chapter-1": return "Chapter 1"
			case "chapter-2": return "Chapter 2"
			case "chapter-3": return "Chapter 3"
			case "chapter-4": return "Chapter 4"
			case "chapter-5": return "Chapter 5"
			case "chapter-6": return "Chapter 6"
			default: return "Unknown Chapter"
		}
	}

	// Format date to a readable string
	private func formattedDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		return formatter.string(from: date)
	}

	// Convert string color to SwiftUI Color
	private func colorForHighlight(_ colorString: String) -> Color {
		switch colorString {
			case "yellow": return Color(red: 1.0, green: 0.92, blue: 0.23)
			case "green": return Color(red: 0.3, green: 0.69, blue: 0.31)
			case "blue": return Color(red: 0.13, green: 0.59, blue: 0.95)
			case "pink": return Color(red: 0.91, green: 0.12, blue: 0.39)
			default: return Color.gray
		}
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			HStack {
				// Color indicator
				RoundedRectangle(cornerRadius: 2)
					.fill(colorForHighlight(highlight.color))
					.frame(width: 4, height: 16)

				Text(chapterTitle)
					.font(.system(size: 12))
					.foregroundColor(.gray)

				Spacer()

				Text(formattedDate(highlight.timestamp))
					.font(.system(size: 10))
					.foregroundColor(.gray)
			}
		}
	}
}

struct HandbookReader_Previews: PreviewProvider {
	static let topic1 = Topic(title: "<h1> The values and principles of the UK </h1>",
							  content: "<p>British society is founded on fundamental values and principles which all those living in the UK should respect and support</p>")
	static let topic2 = Topic(title: "Becoming a permanent resident",
							  content: "<p>To apply to become a permanent resident or citizen of the UK, you will need to:</p> <ul> <li>speak and read English</li> <li>have a good understanding of life in the UK.</li> </ul> <p>There are currently (as of January 2013) two ways you can be tested on these requirements:</p> <ul> <li>Take the Life in the UK test. The questions are written in a way that requires an understanding of the English language at English for Speakers of Other Languages (ESOL) Entry Level 3")

	static let chapter: Chapter = Chapter(title: "Chapter 1 : The values and principles of the UK",
										  topics: [topic1, topic2])
    static var previews: some View {
		NavigationStack {
			HandbookReader(chapter: HandbookReader_Previews.chapter, index: 0)
		}
    }
}
