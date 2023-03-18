//
//  QuestionPageView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 08/03/2023.
//

import SwiftUI

struct Page: PageCarouselItem {
	var identifier: Int
	var title: String
}

struct QuestionPageView: View {
	@State var pages = [Page(identifier: 0, title: "Question 1"),
						Page(identifier: 1, title: "Question 1")]
	@State var selectedPage = 0

	@ObservedObject var viewModel: ExamViewModel
    var body: some View {
		VStack {
			PageCarouselView(pages: $pages, selectedPage: $selectedPage) { page in
				VStack(spacing: 10) {

					QuestionView(viewModel: viewModel, route: .constant(.mockTest))
						.frame(minWidth: 400)
//					.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

					Button { actionButton() } label: {
						Text(">>")
							.bold()
							.foregroundColor(.white)
					}
					.padding()
					.background(.red)
					.clipShape(Circle())

				}
			}
		}
    }
	func actionButton() {
		pages.append(Page(identifier: (pages.count + 1), title: "Question \(pages.count + 1)"))
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			withAnimation {
				selectedPage = pages.count
			}
		}

	}
}

protocol PageCarouselItem: Hashable {
	var identifier: Int { get set }
}

struct PageCarouselView <Content: View>: View {
	@Binding var pages:[Page]
	@Binding var selectedPage: Int

	let foregroundColor: Color
	let backgroundColor: Color
	@ViewBuilder var content: (_: Page) -> Content

	init(pages: Binding<[Page]>,
		 selectedPage: Binding<Int>,
		 foregroundColor: Color = Color.white,
		 backgroundColor: Color = Color.yellow,
		 @ViewBuilder content: @escaping (_: Page) -> Content) {
		self._pages = pages
		self._selectedPage = selectedPage
		self.foregroundColor = foregroundColor
		self.backgroundColor = backgroundColor
		self.content = content
	}
	var body: some View {
		VStack {
			TabView(selection: $selectedPage) {
				ForEach(pages, id: \.identifier) { page in
					GeometryReader { proxy in
						content(page)
							.tag(page.identifier)
							.rotation3DEffect(
								.degrees(proxy.frame(in: .global).minX / -10),
								axis: (x: 0, y: 1, z: 0), perspective: 1
							)
							.shadow(color: Color.black.opacity(0.3),
									radius: 30, x: 0, y: 30)
//							.blur(radius: abs(proxy.frame(in: .global).minX) / 40)

					}
					
				}
			}
			.foregroundColor(foregroundColor)
			.background(backgroundColor)
			.tabViewStyle(.page(indexDisplayMode: .automatic))

		}
	}
}
struct QuestionPageView_Previews: PreviewProvider {
    static var previews: some View {
		let viewModel = ExamViewModel.mock()
		QuestionPageView(viewModel: viewModel)
    }
}
