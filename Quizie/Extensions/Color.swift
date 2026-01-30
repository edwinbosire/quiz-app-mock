//
//  Color.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 30/10/2021.
//

import SwiftUI

struct PastelTheme {
	static var navBackground: Color { Color.green0 }
	static var background: Color { Color.green60 }
	static var title: Color { Color.white }
	static var subTitle: Color {  Color.white.darken  }
	static var bodyText: Color { Color.white }

	static var rowBackground: Color { Color.green0.darken }
	static var searchBarBorder: Color { Color.orange70 }
	static var searchBarBackground: Color { Color.green0.darken(by: 0.65) }
	static var answerRowBackground: Color { Color.white }
	static var answerCorrectBackground: Color { Color.green0 }
	static var answerWrongBackground: Color { Color.pink }


	static var blue = Color(hex: "264653").darken(by: 0.4)
	static var green = Color(hex: "2A9D8F").darken(by: 0.4)
	static var yellow = Color(hex: "E9C46A").darken(by: 0.4)
	static var orange = Color(hex: "F4A261").darken(by: 0.4)
	static var deepOrange = Color(hex: "E76F51").darken(by: 0.4)
}

extension Color {
	static var defaultBackground: Color { Color.green40 }
	static var rowBackground: Color { Color.green0 }
	static var paletteBlue: Color { Color("primary") }
	static var paletteBlueDark: Color { Color("primary") }
	static var paletteBlueSecondary: Color { Color("secondary_1") }
	static var paletteBlueSecondaryDark: Color { Color("secondary") }
	static var titleText: Color { white }
	static var subTitleText: Color {  white.darken  }
	static var bodyText: Color { white }

	static var progressBarTint: Color { Color("secondary-text") }
}

extension Color {
	static var white: Color { Color(hex:"FAFAFA") }

	static var darkGray: Color { Color(hex:"264653") }
	static var green0: Color { Color(hex:"2A9D8F") }
	static var green40: Color { Color(hex:"2A9D8F").darken(by: 0.4)}
	static var green60: Color { Color(hex:"2A9D8F").darken(by: 0.6)}
	static var green70: Color { Color(hex:"2A9D8F").darken(by: 0.7)}

	static var orange70: Color { Color(hex:"E76F51").darken(by: 0.7)}
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

extension Color {
	func darken(by percentage: Double) -> Color {
		let uiColor = UIColor(self)
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0

		uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

		// Multiply each component by (1 - percentage) to add black
		return Color(
			red: red * (1 - percentage),
			green: green * (1 - percentage),
			blue: blue * (1 - percentage)
		)
	}
	var darken: Color {
		self.darken(by: 0.2)
	}

	var lighten: Color {
		self.lighten(by: 0.2)
	}

	func lighten(by percentage: Double) -> Color {
		let uiColor = UIColor(self)
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0

		uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

		// Add white by moving each component toward 1.0 by the given percentage
		return Color(
			red: red + ((1 - red) * percentage),
			green: green + ((1 - green) * percentage),
			blue: blue + ((1 - blue) * percentage)
		)
	}

}
