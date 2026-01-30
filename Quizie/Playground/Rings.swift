//
//  Rings.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 01/02/2025.
//

import SwiftUI

struct ActivityRingsView: View {
	// Progress values for each ring (0.0 to 1.0)
	@State private var moveProgress: CGFloat = 0.75
	@State private var exerciseProgress: CGFloat = 0.55
	@State private var standProgress: CGFloat = 0.35

	var body: some View {
		ZStack {
			RingView(progress: standProgress, ringColor: .blue, lineWidth: 20)
				.frame(width: 200, height: 200)

			RingView(progress: exerciseProgress, ringColor: .green, lineWidth: 20)
				.frame(width: 170, height: 170)

			RingView(progress: moveProgress, ringColor: .red, lineWidth: 20)
				.frame(width: 140, height: 140)

			VStack {
				Text("Activity")
					.font(.title.bold())
					.foregroundColor(.primary)
				Text("Move: \(Int(moveProgress * 100))%")
				Text("Exercise: \(Int(exerciseProgress * 100))%")
				Text("Stand: \(Int(standProgress * 100))%")
			}
			.foregroundColor(.gray)
		}
		.onTapGesture {
			// Animate progress to random values on tap
			withAnimation(.easeInOut(duration: 1.5)) {
				moveProgress = CGFloat.random(in: 0.3...1)
				exerciseProgress = CGFloat.random(in: 0.3...1)
				standProgress = CGFloat.random(in: 0.3...1)
			}
		}
		.padding()
		.background(Color.black.edgesIgnoringSafeArea(.all))
	}
}

struct RingView: View {
	var progress: CGFloat
	var ringColor: Color
	var lineWidth: CGFloat

	var body: some View {
		Circle()
			.stroke(lineWidth: lineWidth)
			.opacity(0.1)
			.foregroundColor(ringColor)

		Circle()
			.trim(from: 0.0, to: progress)
			.stroke(
				AngularGradient(
					gradient: Gradient(colors: [ringColor, ringColor.opacity(0.9)]),
					center: .center
				),
				style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
			)
			.rotationEffect(.degrees(-90)) // Start from the top
			.animation(.easeOut(duration: 1.0), value: progress)
	}
}

#Preview {
	ActivityRingsView()
}

