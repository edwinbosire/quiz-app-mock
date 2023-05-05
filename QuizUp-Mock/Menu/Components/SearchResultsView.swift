//
//  SearchResultsView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 05/05/2023.
//

import SwiftUI

struct SearchResultsView: View {
	@Environment(\.dismiss) var dismiss
	@Binding var queryString: String
	@Binding var isSearching: Bool
	var animation: Namespace.ID
	let bookViewModel = HandbookViewModel.shared

	@FocusState var searchBarFocus: Bool
	var body: some View {
		ZStack {
//			Color.defaultBackground.ignoresSafeArea()
			VStack {
				HStack(spacing: 15) {
					Button(action: {
						withAnimation(.easeOut) {
							isSearching.toggle()
						}}) {
						Image(systemName: "arrow.left")
							.font(.title2)
							.foregroundColor(.titleText)
					}

					HStack {
						Image(systemName: "magnifyingglass")
							.foregroundStyle(.tertiary)

						TextField("Search...", text: $queryString)
							.textCase(.lowercase)
							.autocorrectionDisabled()
							.padding([.top, .bottom, .trailing], 10)
							.tint(Color.titleText)
							.onTapGesture {
//								self.isSearching = true
							}
							.focused($searchBarFocus)
					}
					.padding(.leading)
					.background(
						Capsule()
							.strokeBorder(Color.purple, lineWidth: 1.0)
							.background(.ultraThinMaterial)
							.clipShape(Capsule())
					)
					.matchedGeometryEffect(id: "SEARCHBARID", in: animation)

				}
				.padding(.horizontal)
				.padding(.vertical, 12)
				.onAppear {
//					isSearching = false
					DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
						searchBarFocus = true
					})

				}
				if queryString.isEmpty && searchResults.isEmpty{
					Text("Enter search terms")
						.font(.footnote)
						.foregroundStyle(.secondary)

				}
				if !searchResults.isEmpty {
					Text("Found ") +
					Text("\(searchResults.count) ").bold() +
					Text("chapters")
					List {
						ForEach(searchResults) { chapter in
							Section(chapter.title) {
								ForEach(chapter.topics) { topic in
									VStack(alignment: .leading) {
										Text(topic.title)
											.font(.subheadline)
									}
									.listRowBackground(Color.rowBackground)
								}
							}
						}
					}
					.listStyle(.insetGrouped)
					.scrollContentBackground(.hidden)

				} else if searchResults.isEmpty && !queryString.isEmpty {
					Group {
						Text("No results matching search ").font(.footnote) +
						Text(queryString)
							.font(.callout)
							.bold()
					}.foregroundStyle(.secondary)

				}
			}
//			.gradientBackground()
			.background(.ultraThinMaterial)
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		}
    }

	var searchResults: [Chapter] {
		guard !queryString.isEmpty else {
			return bookViewModel.chapters
		}

		return bookViewModel.chapters.filter { $0.title.localizedCaseInsensitiveContains(queryString) || $0.topics.filter { $0.title.localizedCaseInsensitiveContains(queryString)}.count > 0 }
	}
}

struct SearchResultsView_Previews: PreviewProvider {
	@Namespace static var namespace
    static var previews: some View {
		SearchResultsView(queryString: .constant(""), isSearching: .constant(true), animation: namespace)
    }
}
