//
//  HTMLView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 24/03/2023.
//

import SwiftUI

struct HTMLView: UIViewRepresentable {
	let htmlContent: String
	let font: UIFont
	let foregroundColor: UIColor
	var shouldResizeToFit: Bool = true

	func makeUIView(context: Context) -> UITextView {
		let textView = UITextView()
		textView.isEditable = false
		textView.attributedText = htmlContent.htmlToAttributedString(font: font, foregroundColor: foregroundColor)
		textView.sizeToFit()
		return textView
	}

	func updateUIView(_ uiView: UITextView, context: Context) {
		uiView.attributedText = htmlContent.htmlToAttributedString(font: font, foregroundColor: foregroundColor)
		if shouldResizeToFit {
			uiView.sizeToFit()
		}
	}
}

extension String {
	func htmlToAttributedString(font: UIFont, foregroundColor: UIColor) -> NSAttributedString? {
		guard let data = data(using: .utf8) else { return nil }
		do {
			let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
				.documentType: NSAttributedString.DocumentType.html,
				.characterEncoding: String.Encoding.utf8.rawValue
			]
			let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
			let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
			let range = NSRange(location: 0, length: mutableAttributedString.length)
			mutableAttributedString.addAttribute(.font, value: font, range: range)
			mutableAttributedString.addAttribute(.foregroundColor, value: foregroundColor, range: range)
			return mutableAttributedString
		} catch {
			return nil
		}
	}
}

struct HTMLContentView: View {
	let htmlString = """
<span id=\"553\"> <p>Although Britain is one of the world's most diverse societies, there is a set of shared values and responsibilities that everyone can agree with. These values and responsibilities include:</p> <ul><li>To obey and respect the law</li> <li>To be aware of the rights of others and respect those rights</li> <li>To treat others with fairness</li> <li>To behave responsibly</li> <li>To help and protect your family</li> <li>To respect and preserve the environment</li> <li>To treat everyone equally, regardless of sex, race, religion, age, disability, class or sexual orientation</li> <li>To work to provide for yourself and your family</li> <li>To help others</li> <li>To vote in local and national government elections.</li> </ul></span>
"""
	let font = UIFont.systemFont(ofSize: 18)
	let foregroundColor = UIColor.black
	let shouldResizeToFit = true


	var body: some View {
		HTMLView(htmlContent: htmlString, font: font, foregroundColor: foregroundColor, shouldResizeToFit: shouldResizeToFit)
	}
}


struct HTMLView_Previews: PreviewProvider {
    static var previews: some View {
		HTMLContentView()
    }
}
