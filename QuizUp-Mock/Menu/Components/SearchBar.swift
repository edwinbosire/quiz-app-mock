//
//  SearchBar.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct SearchBar: View {
	@Binding var text: String
	@Binding var isSearching: Bool

	var body: some View {
		HStack {
			Image(systemName: "magnifyingglass")
				.foregroundStyle(.tertiary)
				.padding(.leading)

			TextField("Search...", text: $text)
				.textCase(.lowercase)
				.autocorrectionDisabled()
				.padding([.top, .bottom, .trailing], 8)
				.tint(Color.titleText)
				.onTapGesture {
					withAnimation(.easeInOut) {
						isSearching.toggle()
					}
				}
		}
		.background(
			Capsule()
				.strokeBorder(Color.subTitleText, lineWidth: 0.8)
				.background(.ultraThinMaterial)
				.clipShape(Capsule())
		)
		.overlay(
			closeButton
		)
		.onAppear {
//			isSearching = false
		}
	}

	var closeButton: some View {
		HStack {
			Spacer()
			Button(action: {
				withAnimation {
					self.isSearching.toggle()
				}
				self.text = ""

			}) {
				Image(systemName: "xmark")
					.foregroundColor(Color.primary)
					.foregroundStyle(.primary)

			}
			.padding(.trailing, 10)
			.transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom)))
			.rotation3DEffect(.degrees(isSearching ? 0 : -45), axis: (x: 1, y: 0, z: 0))
			.offset(y: isSearching ? 0 : 20)
			.animation(.easeIn(duration: 0.5), value: isSearching)
		}
		.clipped()
	}
}

struct SearchBar_Previews: PreviewProvider {
	static var previews: some View {
		SearchBar(text: .constant(""), isSearching: .constant(false))
	}
}
