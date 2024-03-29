//
//  Confetti.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 14/03/2023.
//

import SwiftUI

struct ParticlesModifier: ViewModifier {
	@State var time = 0.0
	@State var scale = 0.1
	let duration = 5.0

	func body(content: Content) -> some View {
		ZStack {
			ForEach(0..<80, id: \.self) { index in
				content
					.hueRotation(Angle(degrees: time * 80))
					.scaleEffect(scale)
					.modifier(FireworkParticlesGeometryEffect(time: time))
					.opacity(((duration-time) / duration))
			}
		}
		.onAppear {
			withAnimation (.easeOut(duration: duration)) {
				self.time = duration
				self.scale = 1.0
			}
		}
	}
}

struct FireworkParticlesGeometryEffect : GeometryEffect {
	var time : Double
	var speed = Double.random(in: 20 ... 200)
	var direction = Double.random(in: -Double.pi ...  Double.pi)

	var animatableData: Double {
		get { time }
		set { time = newValue }
	}
	func effectValue(size: CGSize) -> ProjectionTransform {
		let xTranslation = speed * cos(direction) * time
		let yTranslation = speed * sin(direction) * time
		let affineTranslation =  CGAffineTransform(translationX: xTranslation, y: yTranslation)
		return ProjectionTransform(affineTranslation)
	}
}

struct ParticlesModifier_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
			Rectangle()
				.fill(Color.blue)
				.frame(width: 12, height: 12)
				.modifier(ParticlesModifier())
				.offset(x: -100, y : -50)

			Circle()
				.fill(Color.red)
				.frame(width: 12, height: 12)
				.modifier(ParticlesModifier())
				.offset(x: 60, y : 70)
		}
	}
}
