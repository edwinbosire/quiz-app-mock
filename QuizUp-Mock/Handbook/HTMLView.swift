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
	@Binding var fontSize: Double
	@Binding var scrollProgress: Double
//	@Binding var contentOffset: CGPoint?
//	@Binding var contentSize: CGSize?

	var fontJS: String {
		"document.getElementsByTagName('body')[0].style.fontSize='\(fontSize)px'"
	}

	func makeUIView(context: Context) -> WKWebView {
		let webView = WKWebView()

		webView.isOpaque = false
		webView.backgroundColor = .clear
		webView.alpha = 0
		webView.navigationDelegate = context.coordinator
		webView.scrollView.delegate = context.coordinator
		webView.allowsLinkPreview = true
//		webView.evaluateJavaScript(fontJS, completionHandler: nil)
		webView.loadHTMLString(headerString + html, baseURL: nil)

		return webView
	}

	func updateUIView(_ uiView: WKWebView, context: Context) {
		uiView.evaluateJavaScript(fontJS, completionHandler: nil)
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: NSObject, UIScrollViewDelegate, WKNavigationDelegate {
		var parent: HTMLView
		init(_ parent: HTMLView) {
			self.parent = parent
		}

		func scrollViewDidScroll(_ scrollView: UIScrollView) {
			let contentSize = scrollView.contentSize
			let contentOffset = scrollView.contentOffset

			let progress = (contentOffset.y / (contentSize.height-721))*100
			let scrollProgress = min(100, max(0, progress))
			parent.scrollProgress = scrollProgress
		}


		func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
			print("webview did finish loading")
			webView.alpha = 1.0
		}

		
	}
	private static let baseStylesheet: String = {
		guard let fileURL = Bundle.main.url(forResource: "gutenbergContentStyles", withExtension: "css"),
			  let string = try? String(contentsOf: fileURL, encoding: .utf8) else {
			assertionFailure("css missing")
			return ""
		}
		return string
	}()

	var headerString: String {
 """
<header>
<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>
<style>
:root {
color-scheme: light dark;
--background: #ffffff;
--text: #212121;
--accent: #6C10EA;
--h3_background: #F0F8FF;
--list-background: #F0F8FF80;
--font-family: "-apple-system BlinkMacSystemFont, sans-serif";

}

body {
 font-size: \(fontSize)px;
 font-family: "-apple-system BlinkMacSystemFont, sans-serif";
 color: var(--text);
 background-color: var(--background);
}

h1 {
 font:-apple-system-largeTitle3;
}

h3 {
 padding: 10px 15px 10px 10px;
 font:-apple-system-headline;
 background-color: var(--h3_background);
 position: sticky;
 top: 0;
}

ul {
list-style-type: disc;
list-style-position: inside;
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
--background:#11192e;
--text: #E4E4E4;
--accent: #6C10EA;
--h3_background: #2B3964;
--list-background: #2B396480
}
</style>
</header>
"""

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
<H1> The values and pricinples of the UK </H1>
<span id=\"553\"> <p>Although Britain is one of the world's most diverse societies, there is a set of shared values and responsibilities that everyone can agree with. These values and responsibilities include:</p> <ul><li>To obey and respect the law</li> <li>To be aware of the rights of others and respect those rights</li> <li>To treat others with fairness</li> <li>To behave responsibly</li> <li>To help and protect your family</li> <li>To respect and preserve the environment</li> <li>To treat everyone equally, regardless of sex, race, religion, age, disability, class or sexual orientation</li> <li>To work to provide for yourself and your family</li> <li>To help others</li> <li>To vote in local and national government elections.</li> </ul></span>
"""
	let font = UIFont.systemFont(ofSize: 18)
	let foregroundColor = UIColor.black
	let shouldResizeToFit = true
	@State private var scrollProgres: Double = .zero

	var body: some View {
		HTMLView(html: htmlString, fontSize: .constant(100.0), scrollProgress: $scrollProgres)
	}
}


struct HTMLView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationStack {
			HTMLContentView()
		}
    }
}
