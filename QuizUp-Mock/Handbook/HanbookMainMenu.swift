//
//  HanbookMainMenu.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct HanbookMainMenu: View {
	@Binding var route: Route
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Button {route = .mainMenu} label: {
					Image(systemName: "xmark")
						.font(.largeTitle)
				}
				.padding()
			}
			VStack {
				Text("Handbook Under construction")
			}
			.frame(maxHeight: .infinity)
		}
	}
}

struct HanbookMainMenu_Previews: PreviewProvider {
    static var previews: some View {
		HanbookMainMenu(route: .constant(.handbook(chapter: 0)))
    }
}
