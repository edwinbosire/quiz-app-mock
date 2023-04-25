//
//  HandbookReader.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 25/04/2023.
//

import SwiftUI

struct HandbookReader: View {
	let chapter: Book.Chapter
    var body: some View {
		VStack {
			HTMLView(html: chapter.resource)
		}
		.navigationTitle("\(chapter.title) : \(chapter.subTitle)")
    }
}

struct HandbookReader_Previews: PreviewProvider {
    static var previews: some View {
		HandbookReader(chapter: Book().chapters[0])
    }
}
