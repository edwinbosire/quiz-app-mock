//
//  CircularProgressView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 14/03/2023.
//

import SwiftUI

struct CircularProgressView: View {
	@Binding var progress: Double
	var primaryColor: Color = .pink
	var secondaryColor: Color?
	var primaryLineWidth: Double = 20.0

	private var innerStrokeColor: Color {
		secondaryColor ?? primaryColor.lighten(by: 0.8)
	}
	var body: some View {

		Circle()
			.trim(from: 0.0, to: progress)
			.stroke(
				AngularGradient(colors: [primaryColor], center: .center),
				style: StrokeStyle(lineWidth: primaryLineWidth, lineCap: .round, lineJoin: .miter
				)
			)
			.rotationEffect(Angle(degrees: -90.0))
			.animation(.spring, value: progress)
			.background {
				Circle()
					.stroke(lineWidth: primaryLineWidth*0.8)
					.foregroundColor(innerStrokeColor)
			}
	}
}

struct CircularProgressViewContainer: View {
	@State var progress = 0.3
	@State var progress2 = 0.3

	let score: String = "20/24"
	var body: some View {
		VStack {
			ZStack {
				CircularProgressView(progress: $progress)
					.frame(width: 200)

				CircularProgressView(progress: $progress2, primaryColor: .blue)
					.frame(width: 150)
			}

			Spacer()
				.frame(height: 30)
			HStack {
				Slider(value: $progress)

				HStack {
						Image(systemName: "arrow.counterclockwise")
						Text("Reset")
					}
			}

			HStack {
				Slider(value: $progress2)

				HStack {
						Image(systemName: "arrow.counterclockwise")
						Text("Reset")
					}
			}

		}
		.padding()
	}
}
struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
		CircularProgressViewContainer()
    }
}
