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
    var body: some Scene {
        WindowGroup {
			ExamView(viewModel: viewModel)
//			MainMenu()
        }
    }
}
