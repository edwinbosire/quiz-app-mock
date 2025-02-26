//
//  WelcomeBackHeaderView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 14/04/2023.
//

import SwiftUI

struct WelcomeBackHeaderView: View {
	@Environment(\.featureFlags) var featureFlags
	@EnvironmentObject var router: Router

	@State private var queryString: String = ""
	@Binding var isSearching: Bool
	var animation: Namespace.ID

	@State private var count = 0
	@State private var presentHandbookView = false
	let subTitle = "British Citizenship Exam Preparation 2025"

	var body: some View {
		VStack(alignment: .leading) {
			Header()
			Subheading()

			if featureFlags.enableContentSearch {
				SearchBar(text: $queryString, isSearching: $isSearching)
					.matchedGeometryEffect(id: isSearching ? "SEARCHBARID" : "", in: animation)
			}
		}
		.padding()
		.background(Color.rowBackground)
		.background(.ultraThinMaterial)
//		.shadow(color: Color.gray.opacity(0.4), radius: 5, y: 2)
		.onChange(of: queryString) { _, newValue in
			router.navigate(to: .handbookSearch(queryString))
		}

	}

	@ViewBuilder func Header() -> some View {
		HStack {
			Text("Welcome Back")
				.font(.largeTitle)
				.bold()
				.foregroundColor(.titleText)
			Spacer()

			Button(action: {
				router.navigate(to: .settings, navigationType: .sheet)
			}) {
				Image(systemName: "gear")
					.font(.title3)
					.foregroundColor(.titleText)
			}
		}
	}

	@ViewBuilder func Subheading() -> some View {
		TypewriterText(subTitle, count: count)
			.foregroundColor(.subTitleText)
			.foregroundStyle(.secondary)
			.animation(.easeInOut(duration: 1.1), value: count)
			.onAppear {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
					count = subTitle.count
				}
			}
	}
}

struct TypewriterText: View, Animatable {
	var text: String
	var count = 0

	var animatableData: Double {
		get { Double(count) }
		set { count = Int(max(0, newValue)) }
	}

	var body: some View {
		let textToShow = String(text.prefix(count))
		ZStack(alignment: .topLeading) {
			Text(text)
				.opacity(0.1)
				.overlay(
					Text(textToShow), alignment: .topLeading
				)
		}
	}

	init(_ text: String, count: Int = 0) {
		self.text = text
		self.count = count
	}
}
struct WelcomeBackHeaderView_Previews: PreviewProvider {
	@Namespace static var namespace
	static var previews: some View {
		NavigationStack {
			ZStack(alignment: .topLeading) {
				Color("Background")
					.opacity(0.9)
					.ignoresSafeArea()

				WelcomeBackHeaderView(isSearching: .constant(false), animation: namespace)
			}
		}
		.previewDisplayName("Welcome Header")
	}
}
