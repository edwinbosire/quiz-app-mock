//
//  SettingsView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 19/03/2023.
//

import SwiftUI

struct SettingsView: View {
	@Environment(\.dismiss) var dismiss
	@Environment(\.featureFlags) var featureFlags

	@State private var isTimerEnabled = true
	@State private var examDuration = 25.0
	@State private var isDarkModeEnabled = false
	@State private var isProEnabled = true
	@State private var freeExams: Int = 3
	@State private var progressTrackingEnabaled = false


	var body: some View {
		VStack {
			HStack {
				Text("Settings")
					.font(.largeTitle)
					.bold()

				Spacer()
				Button {dismiss()} label: {
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

					examDurationView
					freeExamsLimitView
				}

				Section("App Settings") {
					// add reset button

					Toggle(isOn: $isDarkModeEnabled) {
						Text("Enable Dark Mode")
					}

					Toggle(isOn: $isProEnabled) {
						Text("Enable Pro features")
					}

					Toggle(isOn: $progressTrackingEnabaled) {
						Text("Progress tracking")
					}


				}

				Section("Version") {
					LabeledContent("Version number", value: "1.0")
					LabeledContent("Build number", value: "1.0")
				}
			}
		}
		.onAppear {
			isTimerEnabled = featureFlags.timerEnabled
			progressTrackingEnabaled = featureFlags.progressTrackingEnabled
		}
		.onChange(of: isTimerEnabled) { newValue in
			featureFlags.timerEnabled = newValue
		}
		.onChange(of: progressTrackingEnabaled) { newValue in
			featureFlags.progressTrackingEnabled = newValue
		}
	}

	var examDurationView: some View {
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
		.onAppear {
			examDuration = featureFlags.examDuration
		}
		.onChange(of: examDuration) { newValue in
			featureFlags.examDuration = newValue
		}

	}

	var freeExamsLimitView: some View {
		VStack(alignment: .leading) {
			HStack {
				Stepper("Free Exams \(freeExams)", value: $freeExams, in: 0...10)
			}
		}
		.onAppear {
			freeExams = featureFlags.freeUserExamAllowance
		}
		.onChange(of: freeExams) { newValue in
			featureFlags.freeUserExamAllowance = newValue
		}

	}
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
		SettingsView()
    }
}
