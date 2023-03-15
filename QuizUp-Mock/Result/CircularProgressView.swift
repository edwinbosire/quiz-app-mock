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
	var secondaryColor: Color = .pink.opacity(0.3)
	var primaryLineWidth: Double = 30.0
	var secondaryLineWidth: Double = 30.0

	var body: some View {
		ZStack {
			Circle()
				.stroke( // 1
					secondaryColor,
					lineWidth: secondaryLineWidth
				)

			Circle() // 2
				.trim(from: 0, to: progress)
				.stroke(
					primaryColor,
					style: StrokeStyle(
						lineWidth: secondaryLineWidth,
						lineCap: .round
					)
				)
				.rotationEffect(Angle(degrees: -90))
				.animation(.spring(response: 0.9, dampingFraction: 0.4, blendDuration: 1.0), value: progress)
//				.shadow(color: .black.opacity(0.4), radius: 1, x: 1, y: 1)


			Text(String(format: "%.0f%%", min(self.progress, 1.0)*100.0))
				.font(.largeTitle)
				.monospacedDigit()
				.bold()

		}
	}
}

struct CircularProgressViewContainer: View {
	@State var progress = 0.3
	var body: some View {
		VStack {
			CircularProgressView(progress: $progress)
				.frame(width: 200)

			Spacer()
				.frame(height: 30)
			HStack {
				Slider(value: $progress)

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
