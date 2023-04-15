//
//  SummaryView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 15/04/2023.
//

import SwiftUI

struct SummaryView: View {
	@Binding var route: Route
	@Environment(\.colorScheme) var colorScheme
	var isDarkMode: Bool { colorScheme == .dark }

	var body: some View {
		VStack {
			Spacer()
				.frame(height: 150)
			HStack {
				Button(action: {route = .progressReport}) {
					VStack {
						Text("75 %")
							.font(.largeTitle)
							.bold()
							.foregroundColor(Color.titleText)
						Text("Average score")
							.font(.title3)
							.foregroundStyle(.secondary)
							.foregroundColor(Color.subTitleText)
					}
					.frame(maxWidth: .infinity)
					.frame(height: 150)
					.background(RoundedRectangle(cornerRadius: 10)
						.fill(Color.rowBackground)
						.shadow(color: .black.opacity(0.09), radius: 4, y: 2))
				}
				Spacer()
					.frame(width: 20)

				Button(action: {route = .progressReport}) {
					VStack {
						Text("25 %")
							.font(.largeTitle)
							.bold()
							.foregroundColor(Color.titleText)

						Text("Reading Progress")
							.font(.title3)
							.foregroundStyle(.secondary)
							.foregroundColor(Color.subTitleText)

					}
					.frame(maxWidth: .infinity)
					.frame(height: 150)
					.background(RoundedRectangle(cornerRadius: 10)
						.fill(Color.rowBackground)
						.shadow(color: .black.opacity(0.09), radius: 4, y: 2))
				}
			}
			.padding()
		}
		.padding(.bottom)
		.background(
			Color.defaultBackground
				.clipShape(RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 10))
				.shadow(color: .black.opacity(0.09), radius: 4, x:0.0, y: 2)
		)
	}
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
		SummaryView(route: .constant(.mainMenu))
    }
}
