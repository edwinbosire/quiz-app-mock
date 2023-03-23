//
//  HanbookMainMenu.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct HanbookMainMenu: View {
	let chapter: String
	var body: some View {
		VStack {
			Text("Handbook Under construction")
		}
		.frame(maxHeight: .infinity)
		.navigationTitle(chapter)
	}
}

struct HanbookMainMenu_Previews: PreviewProvider {
    static var previews: some View {
		HanbookMainMenu(chapter: "Test chapter")
    }
}
