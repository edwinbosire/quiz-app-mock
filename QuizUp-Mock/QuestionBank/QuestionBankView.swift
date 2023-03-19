//
//  QuestionBankView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct QuestionBankView: View {
	@Binding var route: Route
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Button {route = .mainMenu} label: {
					Image(systemName: "xmark")
						.font(.largeTitle)
				}
				.padding()
			}
			VStack {
				Text("Under construction")
			}
			.frame(maxHeight: .infinity)
		}
	}
}

struct QuestionBankView_Previews: PreviewProvider {
    static var previews: some View {
		QuestionBankView(route: .constant(.questionbank))
    }
}
