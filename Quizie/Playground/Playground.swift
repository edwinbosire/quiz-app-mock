//
//  Playground.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 18/03/2023.
//

import SwiftUI

struct StackedScrollView<Content: View>: View {
	let pageCount: Int
	@ViewBuilder var content: Content

	var body: some View {
		GeometryReader { geometry in
			ScrollView(.horizontal, showsIndicators: false) {
				ZStack(alignment: .leading) {
					ForEach(0..<pageCount, id: \.self) { i in
						content
							.frame(width: geometry.size.width, height: geometry.size.height)
							.offset(x: CGFloat(i) * geometry.size.width, y: 0)
					}
				}
				.frame(width: geometry.size.width * CGFloat(pageCount), height: geometry.size.height, alignment: .leading)
			}
			.content.offset(x: -geometry.size.width / 2)
		}
	}
}

struct Playground: View {
    var body: some View {
		StackedScrollView(pageCount: 3) {
			Color.red
			Color.green
			Color.blue
				.border(.red)
		}

    }
}

struct Playground_Previews: PreviewProvider {
    static var previews: some View {
        Playground()
    }
}

