//
//  UITextView+html.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 30/03/2025.
//

import UIKit
import SwiftUI

struct HTMLFormattedText: UIViewRepresentable {

	let text: String

	func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
		let textView = UITextView()
		textView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40).isActive = true
		textView.isSelectable = true
		textView.isUserInteractionEnabled = true
		textView.isEditable = false
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.isScrollEnabled = false
		return textView
	}

	func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<Self>) {
		DispatchQueue.main.async {
			if let attributeText = self.converHTML(text: text) {
				uiView.attributedText = attributeText
			} else {
				uiView.text = ""
			}

		}
	}

	private func converHTML(text: String) -> NSAttributedString? {
		guard let data = text.data(using: .utf8) else {
			return nil
		}

		if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
			return attributedString
		} else{
			return nil
		}
	}

}
