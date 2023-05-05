//
//  HTMLView.swift
//  QuizUp-Mock
//
//  Created by Edwin Bosire on 24/03/2023.
//

import SwiftUI
import WebKit

struct HTMLView: UIViewRepresentable {
	let html: String
	let fontSize: Double

	func makeUIView(context: Context) -> WKWebView {
		let webView = WKWebView()
//		webView.scrollView.bounces = false
		return webView
	}

	func updateUIView(_ uiView: WKWebView, context: Context) {
		let headerString =
		"""
 <header>
 <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>
 <style>
 :root {
    color-scheme: light dark;
    --background:#ffffff;
    --text: #212121;
    --accent: #6C10EA;
    --h3_background: #F0F8FF;
    --list-background: #F0F8FF80;
 }

 body {
     font-size: \(fontSize)%;
     font-family: "-apple-system";
     color: var(--text);
     background-color: var(--background);
 }
 h1 {
     font:-apple-system-largeTitle;
 }
 h3 {
     padding: 10px 15px 10px 10px;
     font:-apple-system-headline;
     background-color: var(--h3_background);
     position: sticky;
     top: 0;
 }

 ul {
    list-style-type: none;
    list-style-position: inside;
    list-style-type: circle;
    margin: 0;
    padding: 0;
 }

 li {
   background-color: var(--list-background);
   margin: 1px;
   padding: 10px;
   text-transform: capitalize;
 }

 a:link {
   background-color: #DDFFBB;
   color: red;
   padding: 2px 2px 0px 2px;
   text-align: center;
   text-decoration: none;
   display: inline-block;
   text-transform: lowercase;
   border-radius: 8px;
 }

 @media screen and (prefers-color-scheme: dark) {
   :root {
  color-scheme: light dark;
 --background:#1D2A4F;
 --text: #E4E4E4;
 --accent: #6C10EA;
 --h3_background: #2B3964;
 --list-background: #2B396480
 }
 </style>
 </header>
 """

		uiView.loadHTMLString(headerString + html, baseURL: nil)
	}

	func makeCoordinator() -> Coordinator {
//		Coordinator()
	}

//	class Coordinator: NSObject, UIScrollViewDelegate {
//		func scrollViewDidScroll(_ scrollView: UIScrollView) {
//			if let h1Tags = scrollView.subviews.first?.subviews.filter({ $0 is UILabel && $0.frame.height == 44 }) {
//				for h1 in h1Tags {
//					let h1Y = h1.frame.origin.y
//					if scrollView.contentOffset.y >= h1Y && scrollView.contentOffset.y <= h1Y + h1.frame.height {
//						scrollView.setContentOffset(CGPoint(x: 0, y: h1Y), animated: false)
//					}
//				}
//			}
//		}
//	}
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
<H1> The values and pricinples of the UK </H1>
<span id=\"553\"> <p>Although Britain is one of the world's most diverse societies, there is a set of shared values and responsibilities that everyone can agree with. These values and responsibilities include:</p> <ul><li>To obey and respect the law</li> <li>To be aware of the rights of others and respect those rights</li> <li>To treat others with fairness</li> <li>To behave responsibly</li> <li>To help and protect your family</li> <li>To respect and preserve the environment</li> <li>To treat everyone equally, regardless of sex, race, religion, age, disability, class or sexual orientation</li> <li>To work to provide for yourself and your family</li> <li>To help others</li> <li>To vote in local and national government elections.</li> </ul></span>
"""
	let font = UIFont.systemFont(ofSize: 18)
	let foregroundColor = UIColor.black
	let shouldResizeToFit = true


	var body: some View {
		HTMLView(html: htmlString, fontSize: 100)
	}
}


struct HTMLView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationStack {
			HTMLContentView()
		}
    }
}
