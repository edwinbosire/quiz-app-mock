//
//  QuestionBankView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct QuestionBankView: View {
	@Environment(Router.self) var router
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Button {
					router.popToRoot()
				} label: {
					Image(systemName: "xmark")
						.font(.largeTitle)
				}
				.padding()
			}
			VStack {
				Text("Under construction")
			}
			.frame(maxHeight: .infinity)
		}
	}
}

struct QuestionBankView2: View {
	let colors: [Color] = [.red, .blue, .green, .yellow]
	@State private var currentSelection = 0
	@State private var swipeEnabled = true
	@State private var xoffset: CGFloat = 0.0
	var body: some View {
		TabView(selection: $currentSelection) {
			ForEach(0..<colors.count, id: \.self) { index in
				PageView(color: colors[index], swipeEnabled: $swipeEnabled)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.cornerRadius(10)
					.offset(x: xoffset * Double(index))
			}
		}
		.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
		.gesture(
			DragGesture(minimumDistance: 0, coordinateSpace: .local)
				.onChanged({ value in
//					if !swipeEnabled {
//						return
//					}
					self.xoffset = value.translation.width
					let offset = value.translation.width
					let newIndex = currentSelection - Int(offset / UIScreen.main.bounds.width)
					currentSelection = max(min(newIndex, colors.count - 1), 0)
				})
		)
		.onChange(of: xoffset) { _, newValue in
			print("xOffset \(newValue)")
		}
	}
}

struct PageView: View {
	let color: Color
	@Binding var swipeEnabled: Bool

	var body: some View {
		ZStack {
			Rectangle()
				.fill(color)
//				.frame(height: 200)

			Toggle("Swipe Enabled", isOn: $swipeEnabled)
				.padding()
				.onChange(of: swipeEnabled) {
					// Refresh the page when swipeEnabled changes
					#if os(iOS)
					UIAccessibility.post(notification: .layoutChanged, argument: nil)
					#endif
				}
		}
	}
}

struct QuestionBankView_Previews: PreviewProvider {
    static var previews: some View {
//		QuestionBankView(route: .constant(.questionbank))
		QuestionBankView2()
    }
}
