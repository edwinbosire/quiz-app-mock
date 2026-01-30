//
//  QuestionPageViewScrollView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 09/03/2023.
//

import SwiftUI

struct QuestionPageViewScrollView: View {
	@State var pages = ["Question 1"]

    var body: some View {
		ScrollViewReader { scrollView in

			ScrollView(.horizontal) {
				HStack {
					ForEach(Array(pages.enumerated()), id: \.element) { index, page in
						ZStack {
							Color.black
								.cornerRadius(30.0)
								.frame(width: 300.0)

							Button {
								pages.append("Question \(pages.count + 1)")
								scrollView.scrollTo(3)
							} label: {
								Text("Add +")
									.bold()
									.foregroundColor(.white)
							}

						}
						.id(index)

					}
				}
			}

		}
    }
}

struct QuestionPageViewScrollView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionPageViewScrollView()
    }
}
