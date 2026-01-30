//
//  3DBackground.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 09/03/2025.
//

import SwiftUI

extension View {
	func pastelThemeBackground(_ color: Color) -> some View {
		modifier(PastelThemeBackground(color: color))
	}
}

struct PastelThemeBackground: ViewModifier {
	let color: Color
	let cornerRadius: CGFloat = CornerRadius

	func body(content: Content) -> some View {
		content
		.background {
			RoundedRectangle(cornerRadius: cornerRadius)
				.fill(color.darken)
				.shadow(color: .black.opacity(0.09), radius: 4, y: 2)
				.overlay {
					RoundedRectangle(cornerRadius: cornerRadius)
						.fill(color.lighten)
						.offset(y: -4.0)
				}
		}
		.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
	}

}

struct AnswerRowButton: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.background(
				RoundedRectangle(cornerRadius: CornerRadius)
					.fill(PastelTheme.background.darken)
					.overlay {
						RoundedRectangle(cornerRadius: CornerRadius)
							.fill(PastelTheme.background.lighten)
							.offset(y: -4.0)
					}
			)
			.foregroundStyle(PastelTheme.title)
			.clipShape(RoundedRectangle(cornerRadius: CornerRadius))
	}
}
