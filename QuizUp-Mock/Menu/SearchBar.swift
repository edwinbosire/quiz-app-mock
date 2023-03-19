//
//  SearchBar.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct SearchBar: View {
	@Binding var text: String

		@State private var isEditing = false

		var body: some View {
			HStack {

				TextField("Search ...", text: $text)
					.padding(7)
					.cornerRadius(8)
//					.padding(.horizontal, 10)
					.onTapGesture {
						self.isEditing = true
					}

				ZStack {
					Image(systemName: "magnifyingglass")
						.foregroundStyle(.tertiary)
						.opacity(isEditing ? 0.0 : 1.0)
					if isEditing {
						Button(action: {
							withAnimation {
								self.isEditing = false
							}
							self.text = ""

						}) {
							Image(systemName: "xmark")
								.foregroundStyle(.primary)

						}
						.padding(.trailing, 10)
//						.transition(.move(edge: .trailing))
//						.animation(.default, value: isEditing)
					}
				}
			}
			.padding(.horizontal, 15)

			.background(
				RoundedRectangle(cornerRadius: 10.0)
					.fill(Color("Background"))
					.shadow(color: .black.opacity(0.1), radius: 10, y: 4)

			)
		}}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
		SearchBar(text: .constant("Life in the uk"))
    }
}
