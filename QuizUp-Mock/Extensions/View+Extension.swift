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

extension View {
	func defaultShadow(radius: CGFloat = 9.0, xOffset: CGFloat = 0.0, yOffset: CGFloat = -1.0) -> some View {
		modifier(ShadowStyle(radius: radius, xOffset: xOffset, yOffset: yOffset))
	}
}
