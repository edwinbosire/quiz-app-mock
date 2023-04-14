//
//  WelcomeBackHeaderView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 14/04/2023.
//

import SwiftUI

struct WelcomeBackHeaderView: View {
	@State private var searchText = ""
	var body: some View {
		VStack {
			VStack(alignment: .leading) {
				HStack {
					Text("Welcome Back")
						.font(.largeTitle)
						.bold()
						.foregroundColor(.paletteBlueSecondary)
					Spacer()

					Button(action: { }) {
						Image(systemName: "gear")
							.font(.title3)
							.foregroundColor(Color("primary"))
					}
				}

				Text("British Citizenship Exam Preparation")
					.foregroundStyle(.secondary)

				SearchBar(text: $searchText)
			}
			.padding()
		}
		.background(Color("Background")
		)
		.shadow(color: .black.opacity(0.1), radius: 10, y: 4)

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
