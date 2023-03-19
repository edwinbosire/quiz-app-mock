//
//  ProgressReport.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct ProgressReport: View {
	@Binding var route: Route
	@State var scale = 0.5

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
			.padding()
			VStack {
				Text("Progress Report is under construction")
			}
			.frame(maxHeight: .infinity)
		}
		.scaleEffect(scale)
		.onAppear{
			withAnimation {
				scale = 1.0
			}
		}
	}
}

struct ProgressReport_Previews: PreviewProvider {
    static var previews: some View {
		ProgressReport(route: .constant(.progressReport))
    }
}
