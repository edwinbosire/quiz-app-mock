//
//  SettingsView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct SettingsView: View {
	@Binding var route: Route

	@State private var isTimerEnabled = true
	@State private var examDuration = 25.0
	@State private var isDarkModeEnabled = false
	@State private var isProEnabled = true

	var body: some View {
		VStack {
			HStack {
				Text("Settings")
					.font(.largeTitle)
					.bold()

				Spacer()
				Button {route = .mainMenu} label: {
					Image(systemName: "xmark")
						.font(.largeTitle)
				}
			}
			.padding()

			Form {
				Section("Exam") {
					// Add slider to change exam durations
					// Add toggle to enable timer
					
					Toggle(isOn: $isTimerEnabled) {
						Text("Enable timer")
					}

					VStack(alignment: .leading) {
						HStack {
							Text("Exam duration")
							Spacer()
							Text("\(String(format: "%.0f", examDuration)) minutes")
								.monospacedDigit()
								.foregroundStyle(.secondary)

						}
						Slider(value: $examDuration, in: 1.0...60.0, step: 1.0)
					}


				}

				Section("App Settings") {
					// add reset button

					Toggle(isOn: $isDarkModeEnabled) {
						Text("Enable Dark Mode")
					}

					Toggle(isOn: $isProEnabled) {
						Text("Enable Pro features")
					}


				}

				Section("Version") {
					LabeledContent("Version number", value: "1.0")
					LabeledContent("Build number", value: "1.0")
				}
			}
//			.scrollContentBackground(.hidden)
//			.listRowBackground(Color.red)

		}

	}
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
		SettingsView(route: .constant(.settings))
    }
}
