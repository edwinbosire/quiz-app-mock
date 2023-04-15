//
//  Color.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 30/10/2021.
//

import SwiftUI

extension Color {
	static var defaultBackground: Color { Color("Background") }
	static var rowBackground: Color { Color("RowBackground2")}
	static var paletteBlue: Color { Color("primary") }
	static var paletteBlueDark: Color { Color("primary") }
	static var paletteBlueSecondary: Color { Color("secondary_1") }
	static var paletteBlueSecondaryDark: Color { Color("secondary") }
	static var titleText: Color { Color("primary") }
	static var subTitleText: Color {  Color("secondary-text") }
	static var bodyText: Color { Color("primary_light") }
}

extension Color {
	init(hex: String) {
		let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int: UInt64 = 0
		Scanner(string: hex).scanHexInt64(&int)
		let a, r, g, b: UInt64
		switch hex.count {
		case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			(a, r, g, b) = (1, 1, 1, 0)
		}

		self.init(
			.sRGB,
			red: Double(r) / 255,
			green: Double(g) / 255,
			blue:  Double(b) / 255,
			opacity: Double(a) / 255
		)
	}
}
