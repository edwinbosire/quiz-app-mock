//
//  HanbookMainMenu.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct HanbookMainMenu: View {
	var body: some View {
		List {
			Section("Chapter 1: The values and principles of the UK") {
				BookChapter(title: "1.1 The values and priciples of the UK")
				BookChapter(title: "1.2 Becoming a permanent resident")
				BookChapter(title: "1.3 Taking the Life in the UK test")
			}

			Section("Chapter 2: What is the UK") {
				BookChapter(title: "2.1What is the UK")
			}

			Section("Chapter 3: A long and illustrious history") {
				BookChapter(title: "3.1 Early Britain")
				BookChapter(title: "3.2 The Middle Ages")
				BookChapter(title: "3.3 The Tudors and Stuarts")
				BookChapter(title: "3.4 A Global Power")
				BookChapter(title: "3.5 The 20th Century")
				BookChapter(title: "3.6 Britain Since 1945")
			}

			Section("Chapter 4: A mordern, thriving society") {
				BookChapter(title: "4.1 The UK Today")
				BookChapter(title: "4.2 Religion")
				BookChapter(title: "4.3 Customs and Traditions")
				BookChapter(title: "4.4 Sport")
				BookChapter(title: "4.5 Arts and Culture")
				BookChapter(title: "4.6 Leisure")
				BookChapter(title: "Places of Interest")
			}

			Section("Chapter 5: The UK government, the law and your role") {
				Group {
					BookChapter(title: "5.1 The Development of British Democracy")
					BookChapter(title: "5.2 The British Constitution")
					BookChapter(title: "5.3 The Government")
					BookChapter(title: "5.4 The UK and International Institutions")
					BookChapter(title: "5.5 Respecting the Law")
					BookChapter(title: "5.6 The Role of the Courts")
					BookChapter(title: "5.7 Fundamental Principles")
				}
				Group {
					BookChapter(title: "5.8 Taxation")
					BookChapter(title: "5.9 Driving")
					BookChapter(title: "5.10 Your Role in the Community")
					BookChapter(title: "5.11 How you can Support your Community")
					BookChapter(title: "5.12 Looking After the Environment")
				}
			}

			Section("Key materials and facts") {
				BookChapter(title: "Key materials and facts")
			}


		}
		.frame(maxHeight: .infinity)
		.navigationTitle("Life in the UK Handbook")
	}
}

private struct BookChapter: View {
	let title: String
	var body: some View {
		VStack(alignment: .leading) {
			Text(title)
				.font(.subheadline)
//			Divider()
//				.padding(.leading)
		}

	}
}
struct HanbookMainMenu_Previews: PreviewProvider {
    static var previews: some View {
		HanbookMainMenu()
    }
}
