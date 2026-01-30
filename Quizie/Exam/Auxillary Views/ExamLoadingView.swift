//
//  ExamLoadingView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 09/03/2025.
//

import SwiftUI

struct ExamLoadingView: View {
	var body: some View {
		VStack {
			ProgressView {
				Text("Loading...")
					.font(.headline)
					.foregroundStyle(PastelTheme.title)
			}
			.tint(PastelTheme.title)

		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(PastelTheme.background.gradient)
	}
}

#Preview {
    ExamLoadingView()
}
