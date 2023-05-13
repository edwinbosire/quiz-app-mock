//
//  FeatureFlags.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 02/05/2023.
//

import Foundation
import SwiftUI

class FeatureFlags {
	private let userDefaults = UserDefaults.standard

	private let progressTrackingEnabledKey = "progressTrackingEnabled"
	var progressTrackingEnabled: Bool {
		get { userDefaults.bool(forKey: progressTrackingEnabledKey) }
		set { userDefaults.set(newValue, forKey: progressTrackingEnabledKey)}
	}

	private let fontSizeKey = "fontSize"
	var fontSize: Double {
		get { userDefaults.double(forKey: fontSizeKey) }
		set { userDefaults.set(newValue, forKey: fontSizeKey)}
	}

	private let timerEnabledKey = "timerEnabled"
	var timerEnabled: Bool {
		get { userDefaults.bool(forKey: timerEnabledKey) }
		set { userDefaults.set(newValue, forKey: timerEnabledKey)}
	}

	private let examDurationKey = "examDuration"
	var examDuration: Double {
		get { userDefaults.double(forKey: examDurationKey) }
		set { userDefaults.set(newValue, forKey: examDurationKey)}
	}

	private let enableProFeaturesKey = "enableProFeatures"
	var enableProFeatures: Bool {
		get { userDefaults.bool(forKey: enableProFeaturesKey) }
		set { userDefaults.set(newValue, forKey: enableProFeaturesKey)}
	}

	private let freeUserAllowanceKey = "freeUserExamAllowance"
	var freeUserExamAllowance: Int {
		get { userDefaults.integer(forKey: freeUserAllowanceKey) }
		set { userDefaults.set(newValue, forKey: freeUserAllowanceKey) }
	}

	init() {
		userDefaults.register(
			defaults: [
				progressTrackingEnabledKey: true,
				fontSizeKey: 10.0,
				timerEnabledKey: true,
				examDurationKey: 25.0,
				enableProFeaturesKey: true,
				freeUserAllowanceKey: 4
			]
		)
	}
}

struct FeatureFlagKey: EnvironmentKey {
	static let defaultValue: FeatureFlags = FeatureFlags()
}

extension EnvironmentValues {
	var featureFlags: FeatureFlags {
		get { self[FeatureFlagKey.self] }
		set { self[FeatureFlagKey.self] = newValue }
	}
}
