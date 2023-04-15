//
//  WelcomeBackHeaderView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 14/04/2023.
//

import SwiftUI

struct WelcomeBackHeaderView: View {
	@State private var searchText = ""
	@State var isShowingSettings = false

	var body: some View {
		VStack {
			VStack(alignment: .leading) {
				HStack {
					Text("Welcome Back")
						.font(.largeTitle)
						.bold()
						.foregroundColor(.titleText)
					Spacer()

					Button(action: { isShowingSettings.toggle() }) {
						Image(systemName: "gear")
							.font(.title3)
							.foregroundColor(.titleText)
					}
				}

				Text("British Citizenship Exam Preparation")
					.foregroundColor(.subTitleText)
					.foregroundStyle(.secondary)

				SearchBar(text: $searchText)
			}
			.padding()
		}
		.background(Color.rowBackground)
		.shadow(color: .black.opacity(0.09), radius: 4, y: 2)
		.sheet(isPresented: $isShowingSettings) {
			SettingsView()
		}

	}
}


struct WelcomeBackHeaderView_Previews: PreviewProvider {

	static var previews: some View {
		NavigationStack {
			ZStack(alignment: .topLeading) {
				Color("Background")
					.opacity(0.9)
					.ignoresSafeArea()

				WelcomeBackHeaderView()
			}
		}
		.previewDisplayName("Welcome Header")
	}
}
