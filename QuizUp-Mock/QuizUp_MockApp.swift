//
//  QuizUp_MockApp.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 29/10/2021.
//

import SwiftUI

@main
struct QuizUp_MockApp: App {
	@ObservedObject var viewModel = ExamViewModel.mock()
	@State var route: Route = .mainMenu
    var body: some Scene {
        WindowGroup {
			switch route {
				case .mainMenu:
					MainMenu(route: $route)
				case .mockTest:
					ExamView(viewModel: viewModel, route: $route)
				case .handbook:
					PlaceHolder(route: $route)
				case .questionbank:
					PlaceHolder(route: $route)
			}

        }
    }
}

enum Route {
	case mainMenu
	case mockTest
	case handbook
	case questionbank
}

struct PlaceHolder: View {
	@Binding var route: Route
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Button {route = .mainMenu} label: {
					Image(systemName: "xmark")
				}
			}
			VStack {
				Text("Under construction")
			}
			.frame(maxHeight: .infinity)
		}
	}
}

//struct PlaceHolder_Previews: PreviewProvider {
//	static var previews: some View {
//		PlaceHolder()
//	}
//}
