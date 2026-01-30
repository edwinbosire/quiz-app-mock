//
//  StickyHeader.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 08/03/2025.
//

import SwiftUI

extension View {
	func useStickyHeaders() -> some View {
		modifier(UseStickyHeaders())
	}

	func sticky() -> some View {
		modifier(Sticky())
	}
}

struct UseStickyHeaders: ViewModifier {
	@State private var frames: StickyRects.Value = [:]

	func body(content: Content) -> some View {
		content
			.onPreferenceChange(FramePreference.self) { frames = $0 }
			.environment(\.stickyRects, frames)
	}
}


struct Sticky: ViewModifier {
	@Environment(\.stickyRects) var stickyRects
	@State private var frame: CGRect = .zero
	@Namespace private var id

	var isSticking: Bool {
		frame.minY < 0
	}

	var offset: CGFloat {
		guard isSticking else { return 0 }
		guard let stickyRects else {
			print("Warning: Using .sticky() without .useStickyHeaders()")
			return 0
		}
		var o = -frame.minY
		if let other = stickyRects.first(where: { (key, value) in
			key != id && value.minY > frame.minY && value.minY < frame.height
		}) {
			o -= frame.height - other.value.minY
		}

		return o
	}

	func body(content: Content) -> some View {
		content
			.offset(y: offset)
			.zIndex(isSticking ? .infinity : 0)
			.onGeometryChange(for: CGRect.self) { proxy in
				proxy.frame(in: .scrollView)
			} action: { newFrame in
				frame = newFrame
			}

	}
}

struct FramePreference: PreferenceKey {
	static var defaultValue: [Namespace.ID: CGRect] = [:]

	static func reduce(value: inout Value, nextValue: () -> Value) {
		value.merge(nextValue()) { $1 }
	}
}

enum StickyRects: EnvironmentKey {
	static var defaultValue: [Namespace.ID: CGRect]? = nil
}

extension EnvironmentValues {
	var stickyRects: StickyRects.Value {
		get { self[StickyRects.self] }
		set { self[StickyRects.self] = newValue }
	}
}
