//
//  HandbookReader.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 25/04/2023.
//

import SwiftUI

struct HandbookReader: View {
	@Environment(\.featureFlags) var featureFlags

	let chapter: Chapter
	@State var fontSize: Double = 120
	@State private var selection = 0

	var body: some View {
		GeometryReader { proxy in
			TabView(selection: $selection) {
				ForEach(Array(chapter.topics.enumerated()), id: \.offset) { ndx, topic in
					HandbookTopicReader(topic: topic, fontSize: fontSize).tag(ndx)
				}
			}
			.ignoresSafeArea()

		}
		.tabViewStyle(.page(indexDisplayMode: .never))
		.navigationBarTitle(Text(chapter.title.components(separatedBy: ":").first ?? ""), displayMode: .inline)
		.navigationBarItems(trailing: HStack {
			Button(action: {fontSize += 10}) {
				Image(systemName: "textformat.size.larger")
			}

			Button(action: {fontSize -= 10}) {
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
		.toolbarBackground(Color.pink, for: .navigationBar)
		.background(
			LinearGradient(colors: [Color.blue.opacity(0.5), Color.defaultBackground,Color.defaultBackground, Color.blue.opacity(0.5)], startPoint: .top, endPoint: .bottom)
				.blur(radius: 75)
		)
		.onAppear {
			fontSize = featureFlags.fontSize
		}
		.onChange(of: fontSize) { newValue in
			featureFlags.fontSize = newValue
		}

	}
}

struct  HandbookTopicReader: View {
	var topic: Topic
	var fontSize: Double
	var body: some View {
			VStack(alignment: .leading, spacing: 10.0) {
				let title = "<H1>\(topic.title) </H1>"
				HTMLView(html: "\(title) \(topic.content)", fontSize: fontSize)
					.frame(maxHeight: .infinity)

			}
			.frame(maxHeight: .infinity)
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
			HandbookReader(chapter: HandbookReader_Previews.chapter)
		}
		.toolbarBackground(Color.defaultBackground, for: .navigationBar)
    }
}
