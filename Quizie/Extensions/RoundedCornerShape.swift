//
//  RoundedCornerShape.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 16/03/2023.
//

import SwiftUI

struct RoundedCornersShape: Shape {
	let corners: UIRectCorner
	let radius: CGFloat

	func path(in rect: CGRect) -> Path {
		let path = UIBezierPath(roundedRect: rect,
								byRoundingCorners: corners,
								cornerRadii: CGSize(width: radius, height: radius))
		return Path(path.cgPath)
	}
}
