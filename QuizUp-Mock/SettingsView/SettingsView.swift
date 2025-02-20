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
	@AppStorage("appearance") private var appearance: Appearance = .system

	@State private var isTimerEnabled = true
	@State private var examDuration = 25.0
	@State private var enableDarkMode = false
	@State private var isProEnabled = true
	@State private var freeExams: Int = 3
	@State private var progressTrackingEnabaled = false
	@State private var enableContentSearch = false


	var body: some View {
		VStack {
			HStack {
				Text("Settings")
					.font(.title)
					.bold()

				Spacer()
				Button {dismiss()} label: {
					Image(systemName: "xmark")
						.font(.title)
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

					AppearanceSettings()
					Toggle(isOn: $isProEnabled) {
						Text("Enable Pro features")
					}

					Toggle(isOn: $progressTrackingEnabaled) {
						Text("Progress tracking")
					}

					Toggle(isOn: $enableContentSearch) {
						Text("Enable Content Search")
					}
				}

				Section("Version") {
					LabeledContent("Version number", value: "1.0 (11)")
				}
			}
		}
		.preferredColorScheme(appearance.colorScheme)
		.onAppear {
			isTimerEnabled = featureFlags.timerEnabled
			progressTrackingEnabaled = featureFlags.progressTrackingEnabled
			enableContentSearch = featureFlags.enableContentSearch
			enableDarkMode = featureFlags.enableDarkMode
		}
		.onChange(of: isTimerEnabled) { _, newValue in
			featureFlags.timerEnabled = newValue
		}
		.onChange(of: progressTrackingEnabaled) { _, newValue in
			featureFlags.progressTrackingEnabled = newValue
		}
		.onChange(of: enableContentSearch) { _, newValue in
			featureFlags.enableContentSearch = newValue
		}
		.onChange(of: enableDarkMode) { _, newValue in
			featureFlags.enableDarkMode = newValue
		}

	}

	@ViewBuilder func AppearanceSettings() -> some View {
		Picker("Appearance", selection: $appearance) {
			ForEach(Appearance.allCases) { appearance in
				Text(appearance.rawValue.capitalized)
			}
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
		.onChange(of: examDuration) { _, newValue in
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
		.onChange(of: freeExams) { _, newValue in
			featureFlags.freeUserExamAllowance = newValue
		}

	}
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
		SettingsView()
    }
}
