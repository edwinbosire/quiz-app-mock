//
//  WelcomeBackHeaderView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 14/04/2023.
//

import SwiftUI

struct WelcomeBackHeaderView: View {
	@State private var queryString: String = ""
	@Binding var isSearching: Bool
	var animation: Namespace.ID

	@State var isShowingSettings = false
	@State private var count = 0
	@State private var presentHandbookView = false
	let subTitle = "British Citizenship Exam Preparation"

	var body: some View {
			VStack {
				VStack(alignment: .leading) {
					HStack {
						Text("Welcome Back")
							.font(.largeTitle)
							.bold()
							.foregroundColor(.titleText)
						Spacer()
//#if DEBUG
						Button(action: { isShowingSettings.toggle() }) {
							Image(systemName: "gear")
								.font(.title3)
								.foregroundColor(.titleText)
						}
//#endif
					}

					TypewriterText(subTitle, count: count)
						.foregroundColor(.subTitleText)
						.foregroundStyle(.secondary)
						.animation(.easeInOut(duration: 1.1), value: count)
						.onAppear {
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
								count = subTitle.count
							}
						}

					if isSearching {
						SearchBar(text: $queryString, isSearching: $isSearching)
					} else {
						SearchBar(text: $queryString, isSearching: $isSearching)
							.matchedGeometryEffect(id: "SEARCHBARID", in: animation)
					}

				}
				.padding()
			}
			//		.background(Color.rowBackground)
			.background(.ultraThinMaterial)
			.shadow(color: .black.opacity(0.09), radius: 4, y: 2)
			.sheet(isPresented: $isShowingSettings) {
				SettingsView()
			}

//			.onChange(of: queryString) { newValue in
//				presentHandbookView = !newValue.isEmpty
//			}
//			.sheet(isPresented: $presentHandbookView) {
//				NavigationView {
//					HanbookMainMenu(queryString: queryString)
//				}
//
//			}
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
