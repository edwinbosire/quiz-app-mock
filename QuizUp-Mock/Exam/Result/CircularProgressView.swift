//
//  CircularProgressView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 14/03/2023.
//

import SwiftUI

struct CircularProgressView: View {
	@Binding var progress: Double
	let score: String
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
					AngularGradient(colors: [.red, .yellow, .green, .red], center: .center),
					style: StrokeStyle(
						lineWidth: secondaryLineWidth,
						lineCap: .round
					)
				)
				.rotationEffect(Angle(degrees: -90))
				.animation(.spring(response: 0.9, dampingFraction: 0.4, blendDuration: 1.0), value: progress)

			VStack {
				Text(String(format: "%.0f%%", min(self.progress, 1.0)*100.0))
					.font(.largeTitle)
					.monospacedDigit()
					.bold()

				Text(score)
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
	}
}

struct CircularProgressViewContainer: View {
	@State var progress = 0.3
	let score: String = "20/24"
	var body: some View {
		VStack {
			CircularProgressView(progress: $progress, score: score)
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
