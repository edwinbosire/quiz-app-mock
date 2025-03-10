//
//  TopicProgressView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 06/05/2023.
//

import SwiftUI

struct TopicProgressView: View {
	var value: CGFloat = 0.5
	var lineWidth: Double = 2

	@State var appear = false

	var body: some View {
		backgroundRing
			.overlay(
				Circle()
					.trim(from: 0, to: appear ? value : 0)
					.stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
					.fill(.angularGradient(colors: [.purple, .orange, .purple], center: .center, startAngle: .degrees(0), endAngle: .degrees(360)))
					.rotationEffect(.degrees(270))
					.onAppear {
						withAnimation(.spring().delay(0.5)) {
							appear = true
						}
					}
					.onDisappear {
						appear = false
					}
			)
	}

	var backgroundRing: some View {
		Circle()
			.stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
			.fill(Color.green40)
	}
}


struct TopicProgressView_Previews: PreviewProvider {
    static var previews: some View {
		TopicProgressView()
    }
}
