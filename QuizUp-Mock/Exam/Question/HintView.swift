//
//  HintView.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 25/03/2023.
//

import SwiftUI

struct HintView: View {
	@ObservedObject var viewModel: QuestionViewModel
	@Binding var isPresented: Bool

	var body: some View {
		VStack {
			HStack {
				Button(action: {
					withAnimation(.easeInOut) {
						isPresented = false
					}
				}) {
					Image(systemName: "chevron.down")
						.font(.title)
				}

				Spacer()
				Text("Explanation")
					.font(.title3)
					.bold()
				Spacer()
				Button(action: {
					withAnimation(.easeInOut) {
						isPresented = false
						viewModel.owner?.progressToNextQuestions()
					}

				}) {
					Image(systemName: "arrow.right")
						.font(.title)
				}
			}
			.foregroundColor(.paletteBlue)
			.padding()

			Spacer()
			ScrollView {
				Text(viewModel.hint)
					.font(.callout)
					.lineSpacing(12.0)
					.foregroundStyle(.primary)
					.padding(.horizontal)
					.presentationDetents([.height(150), .medium, .large])
				Spacer()
			}

		}
		.background(
			Color("Background")
				.opacity(0.9)
				.ignoresSafeArea()
		)
	}
}

struct HintView_Previews: PreviewProvider {
    static var previews: some View {
		let viewModel = ExamViewModel.mock()

		HintView(viewModel: viewModel.questions[0], isPresented: .constant(true))
    }
}
