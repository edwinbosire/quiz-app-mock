//
//  TextFieldStyle.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 31/01/2026.
//

import SwiftUI

struct TextFieldStyleDemo: View {
    var body: some View {
		TextField("Some Text Goes Here", text: .constant(""))
			.textFieldStyle(.flashcard)
			.padding()
    }
}

struct FlashcardTextFieldStyle: TextFieldStyle {
	func _body(configuration: TextField<Self._Label>) -> some View {
				configuration
					.padding()
					.background(Color.gray.opacity(0.1))
					.border(Color.gray.opacity(0.07), width: 2)

	}
}

extension TextFieldStyle where Self == FlashcardTextFieldStyle{
	static var flashcard: FlashcardTextFieldStyle { FlashcardTextFieldStyle()
	}
}
#Preview {
	TextFieldStyleDemo()
}
