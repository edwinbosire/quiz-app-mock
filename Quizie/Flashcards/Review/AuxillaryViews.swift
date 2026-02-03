//
//  AuxillaryViews.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 02/02/2026.
//

import SwiftUI

struct StatRowView: View {
	let label: String
	let value: String

	var body: some View {
		HStack {
			Text(label)
				.foregroundStyle(.secondary)
			Spacer()
			Text(value)
				.fontWeight(.semibold)
		}
	}
}

struct MiniStatView: View {
	let emoji: String
	let count: Int
	let color: Color

	var body: some View {
		VStack(spacing: 4) {
			Text(emoji)
				.font(.title2)
			Text("\(count)")
				.font(.headline)
				.foregroundStyle(color)
		}
	}
}


#Preview {
	StatRowView(label: "Example", value: "80.0")
	MiniStatView(emoji: "internaldrive", count: 10, color: .pink)
}
