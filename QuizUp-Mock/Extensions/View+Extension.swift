//
//  View+Extension.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 18/03/2023.
//

import SwiftUI

struct ShadowStyle: ViewModifier {
	@Environment(\.colorScheme) var colorScheme
	var isDarkMode: Bool { colorScheme == .dark }
	var radius: CGFloat = 9.0
	var xOffset: CGFloat = 0.0
	var yOffset: CGFloat = -1.0
	func body(content: Content) -> some View {
		content
			.shadow(color: .black.opacity(isDarkMode ? 0.2 : 0.1), radius: radius, x: xOffset, y: yOffset)
	}
}

private struct GradientBackground: ViewModifier {
	@Environment(\.colorScheme) var colorScheme
	var isDarkMode: Bool { colorScheme == .dark }
	func body(content: Content) -> some View {
		let colors = isDarkMode ? [Color.blue.opacity(0.5), Color.purple, Color.defaultBackground,Color.defaultBackground, Color.blue.opacity(0.5)] :
		[Color.defaultBackground, Color.purple.opacity(0.3), Color.defaultBackground]
		content
			.background(
					LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
						.blur(radius: 75)

			)
	}
}

extension View {
	func defaultShadow(radius: CGFloat = 9.0, xOffset: CGFloat = 0.0, yOffset: CGFloat = -1.0) -> some View {
		modifier(ShadowStyle(radius: radius, xOffset: xOffset, yOffset: yOffset))
	}

	func gradientBackground() -> some View {
		modifier(GradientBackground())
	}
}

extension View {
	@ViewBuilder func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
}

