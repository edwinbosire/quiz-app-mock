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
	var primaryLineWidth: Double = 20.0

	var body: some View {
		ZStack {
			Circle()
				.stroke(lineWidth: primaryLineWidth)
				.foregroundColor(primaryColor)
				.opacity(0.4)

			Circle() // 2
				.trim(from: 0.0, to: progress)
				.stroke(
					AngularGradient(colors: [primaryColor], center: .center),
					style: StrokeStyle(
						lineWidth: primaryLineWidth,
						lineCap: .round
					)
				)
				.rotationEffect(Angle(degrees: -90))
				.animation(.spring(response: 0.9, dampingFraction: 0.4, blendDuration: 1.0), value: progress)

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
