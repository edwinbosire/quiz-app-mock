//
//  HanbookMainMenu.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct HanbookMainMenu: View {
	let chapter: Book.Chapter
	var body: some View {
		VStack {
			HTMLView(html: chapter.resource)
		}
		.frame(maxHeight: .infinity)
		.navigationTitle("\(chapter.title) | \(chapter.subTitle)")
	}
}

struct HanbookMainMenu_Previews: PreviewProvider {
    static var previews: some View {
		HanbookMainMenu(chapter: Book().chapters[0])
    }
}
