//
//  SearchResultsView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 05/05/2023.
//

import SwiftUI
import Combine

struct SearchResultsView: View {
	@Environment(\.dismiss) var dismiss
	@ObservedObject var viewModel: MenuViewModel
	@State private var queryString: String = ""
	@State private var searchResults: [Chapter] = []

	var animation: Namespace.ID
	let bookViewModel = HandbookViewModel.shared

	@FocusState var searchBarFocus: Bool
	var body: some View {

			VStack {
				navigationBar
//					.onAppear {
//						DispatchQueue.main
//							.asyncAfter(deadline: .now() + 1, execute: {
//								searchBarFocus = true
//							})
//
//					}

				if queryString.isEmpty && searchResults.isEmpty{
					Text("Enter search terms")
						.font(.footnote)
						.foregroundStyle(.secondary)
				}
				if !searchResults.isEmpty && !queryString.isEmpty {
					Text("Found ") +
					Text("\(searchResults.count) ").bold() +
					Text("chapters")
				}
				if !searchResults.isEmpty {
					HandbookMainMenuList(
						chapters: searchResults,
						queryString: $queryString
					)

				} else if searchResults.isEmpty && !queryString.isEmpty {
					ZStack(alignment: .top) {
						Color.defaultBackground
							.blur(radius: 40)
							.ignoresSafeArea()
						Group {
							Text("No results matching search ")
								.font(.footnote) +
							Text(queryString)
								.font(.callout)
								.bold()
						}.foregroundStyle(.secondary)
					}

				}
			}
			.background(Color.teal.ignoresSafeArea())
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.onChange(of: queryString) { _, newValue in
				if !newValue.isEmpty {
					searchResults = search(newValue)
				}
			}
			.onAppear {
				searchResults = bookViewModel.chapters
			}

	}

	var navigationBar: some View {
		HStack(spacing: 15) {
			Button(action: {
				withAnimation(.easeOut) {
					viewModel.isSearching.toggle()
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
					.keyboardType(.default)
					.submitLabel(.search)
					.onSubmit { viewModel.isSearching = false }
					.onTapGesture {
						viewModel.isSearching = true
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
	}

	func search(_ query: String) -> [Chapter] {
		guard !query.isEmpty else {
			return bookViewModel.chapters
		}

		return bookViewModel.chapters.filter { $0.title.localizedCaseInsensitiveContains(queryString) || $0.topics.filter { $0.title.localizedCaseInsensitiveContains(queryString)}.count > 0 }
	}

	func expensiveSearch(_ query: String) -> [(Chapter, String)]  {
		var results: [(Chapter, String)] = []
		bookViewModel.chapters.forEach { chapter in
			for topic in chapter.topics {
				if topic.content.contains(query) {
					let matchingContent = ""
					let largeText = topic.content
//					let startIndex = largeText.startIndex

					let contentResults = searchContent(largeText, for: query)
					if !contentResults.isEmpty {
						print("\(query) found at the following positions:")
						for (index, range) in contentResults.enumerated() {
							print("Occurrence \(index + 1): \(largeText.distance(from: largeText.startIndex, to: range.lowerBound))")
							let sIndex = largeText.distance(from: largeText.startIndex, to: range.lowerBound)
							let startIndex = largeText.index(largeText.startIndex, offsetBy: sIndex)
							let endIndex = largeText.distance(from: largeText.startIndex, to: range.upperBound)
							let foundOccourence = largeText[range.lowerBound..<range.upperBound]
							print("found: \(foundOccourence)")
						}
					} else {
						print("'\(query)' not found.")
					}

					results.append((chapter, matchingContent))
				}
			}
		}
		return results
	}

	func searchContent(_ largeText: String, for searchString: String) -> [Range<String.Index>] {
		var searchStartIndex = largeText.startIndex
		var searchRanges: [Range<String.Index>] = []

		let options: String.CompareOptions = .caseInsensitive

		while let range = largeText.range(of: searchString, options: options, range: searchStartIndex..<largeText.endIndex) {
			searchRanges.append(range)
			searchStartIndex = range.upperBound
		}
		return searchRanges
	}
}

struct SearchResultsView_Previews: PreviewProvider {
	@Namespace static var namespace
    static var previews: some View {
		SearchResultsView(viewModel: MenuViewModel(), animation: namespace)
    }
}
