//
//  Chevrons.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 01/02/2025.
//

import SwiftUI

struct MovingRightIndicator: View {
	@State private var moveRight = false
	@State private var colorShift = false

	// Color palette for animation
	let colors: [Color] = [.blue, .purple, .pink, .orange, .yellow]

	var body: some View {
		HStack(spacing: 4) {
			ForEach(0..<3) { index in
				Image(systemName: "chevron.right")
					.font(.body)
					.fontWeight(.bold)
					.foregroundColor(colorShift ? colors[index % colors.count] : colors.reversed()[index % colors.count])
					.opacity(moveRight ? Double(index + 1) * 0.4 : 0.2) // Fading effect
					.offset(x: moveRight ? 10 : -10) // Move right and left
					.animation(
						Animation.easeInOut(duration: 1.6)
							.repeatForever()
							.delay(Double(index) * 0.2), // Staggered movement
						value: moveRight
					)
					.animation(
						Animation.linear(duration: 1.5)
							.repeatForever()
							.delay(Double(index) * 0.3), // Color shift with a slight delay
						value: colorShift
					)
			}
		}
		.onAppear {
			moveRight.toggle()
			colorShift.toggle()
		}
		.padding()
	}
}

#Preview {
	MovingRightIndicator()
}
