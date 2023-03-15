//
//  MainMenu.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 15/03/2023.
//

import SwiftUI

struct MainMenu: View {
    var body: some View {
		ZStack {
			Color("Background").ignoresSafeArea()

			content
				.background(Image("Blob 1").offset(x: 100, y: -90))
		}
    }

	var content: some View {
		VStack {
			MenuButtons(title: "Mock Test", backgroundColor: .pastelBlue)
//				.background(mockTestBackground)
//			MenuButtons(title: "Practice Test", backgroundColor: .paletteBlue)
			MenuButtons(title: "Handbook", backgroundColor: .pastelBrown)
			MenuButtons(title: "Question Bank", backgroundColor: .pastelLightBrow)
		}
	}

	var mockTestBackground: RadialGradient {
		RadialGradient(gradient: Gradient(colors: [.pastelBlue, .pink]), center: UnitPoint(x: 0.5, y: 0.8), startRadius: 0, endRadius: 650)

	}
}

struct MenuButtons: View {
	let title: String
	let backgroundColor: Color
	var foregroundColor: Color = .white
	var body: some View {
		Button {

		} label: {

			Text(title)
				.font(.title)
				.bold()
				.foregroundColor(foregroundColor)
		}
		.background(
			RoundedRectangle(cornerRadius: 30)
				.fill(backgroundColor.gradient)
				.frame(height: 100)
				.padding(.horizontal)

		)


	}
}
struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
    }
}

extension Color {
	static var pastelBlue: Color {
		Color(red: 0.310, green: 0.416, blue: 0.561, opacity: 1.000)
	}
	static var pastelLightBlue: Color {
		Color(red: 0.533, green: 0.635, blue: 0.737, opacity: 1.000)
	}
	static var pastelThinBrown: Color {
		Color(red: 0.941, green: 0.859, blue: 0.690, opacity: 1.000)
	}
	static var pastelLightBrow: Color {
		Color(red: 0.937, green: 0.714, blue: 0.502, opacity: 1.000)
	}
	static var pastelBrown: Color {
		Color(red: 0.851, green: 0.580, blue: 0.467, opacity: 1.000)
	}
}
