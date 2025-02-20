//
//  FrameReader.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 01/02/2025.
//

import SwiftUI

// Custom ViewModifier to measure height
struct FramePreferenceKey: PreferenceKey {
	static var defaultValue: CGSize = .zero
	static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
		value = nextValue()
	}
}

struct FrameReader: ViewModifier {
	@Binding var height: CGFloat
	@Binding var width: CGFloat
	@Binding var frame: CGSize
	func body(content: Content) -> some View {
		content
			.background(
				GeometryReader { geometry in
					Color.clear
						.preference(key: FramePreferenceKey.self, value: geometry.size)
				}
			)
			.onPreferenceChange(FramePreferenceKey.self) { _frame in
				height = _frame.height
				width = _frame.width
				frame = frame
			}
	}
}

extension View {
	func readHeight(_ height: Binding<CGFloat>) -> some View {
		self.modifier(FrameReader(height: height, width: .constant(0), frame: .constant(.zero)))
	}

	func readWidth(_ width: Binding<CGFloat>) -> some View {
		self.modifier(FrameReader(height: .constant(0.0), width: width, frame: .constant(.zero)))
	}

	func readFrame(_ frame: Binding<CGSize>) -> some View {
		self.modifier(FrameReader(height: .constant(0.0), width: .constant(0.0), frame: frame))
	}
}
