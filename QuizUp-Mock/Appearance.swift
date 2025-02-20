//
//  Appearance.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 31/01/2025.
//

import SwiftUI

enum Appearance: String, CaseIterable, Identifiable {
	case system
	case light
	case dark

	var id: Self { self }

	// Map Appearance cases to SwiftUI's ColorScheme
	var colorScheme: ColorScheme? {
		switch self {
		case .system: return nil // Follow system
		case .light: return .light
		case .dark: return .dark
		}
	}
}
