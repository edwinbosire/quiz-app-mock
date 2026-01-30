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
	let chapterId: String
	@Binding var fontSize: Double
	@Binding var scrollProgress: Double
	@ObservedObject var highlightManager: HighlightManager

	var fontJS: String {
		"""
  document.getElementsByTagName('body')[0].style.fontSize='\(fontSize)px'
  document.getElementsByTagName('h1')[0].style.fontSize='\(fontSize + 10)px'
  document.getElementsByTagName('h2')[0].style.fontSize='\(fontSize + 5)px'

  """
	}

	func makeUIView(context: Context) -> WKWebView {
		// Create a user content controller
		let userContentController = WKUserContentController()
		let script = WKUserScript(source: javascript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
		userContentController.addUserScript(script)

		userContentController.add(context.coordinator, name: "highlightHandler")
//		userContentController.add(context.coordinator, name: "scrollProgressHandler")
//		userContentController.add(context.coordinator, name: "newSelectionDetected")


		// Create configuration with user content controller
		let configuration = WKWebViewConfiguration()
		configuration.userContentController = userContentController
		configuration.defaultWebpagePreferences.allowsContentJavaScript = true

		let webView = WKWebView(frame: .zero, configuration: configuration)
		webView.isOpaque = false
		webView.backgroundColor = .white
		webView.navigationDelegate = context.coordinator
		webView.scrollView.delegate = context.coordinator
		webView.allowsLinkPreview = true

		let styledHTML = formatHTML(content: html, fontSize: fontSize)
		webView.loadHTMLString(styledHTML, baseURL: URL.applicationDirectory)

		return webView
	}

	func updateUIView(_ uiView: WKWebView, context: Context) {
		uiView.evaluateJavaScript(fontJS, completionHandler: nil)
	}

	func makeCoordinator() -> WebViewCoordinator {
		WebViewCoordinator(self)
	}

	private func formatHTML(content: String, fontSize: CGFloat = .zero) -> String {
		return """
		<!DOCTYPE html>
		<html>
		<head>
			<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
				  <meta http-equiv="Content-Security-Policy" content="default-src * 'unsafe-inline' 'unsafe-eval' data: blob:;">
			<meta charset="UTF-8">
			\(css)
		<script>
			\(javascript)
		</script>
		</head>
		<body>
			\(content)
		</body>
		</html>
		"""
	}

}

// Loads file named javascript from bundle
var javascript: String = {
	guard let fileURL = Bundle.main.url(forResource: "javascript", withExtension: "js") else {
		return ""
	}


	if let script = try? String(contentsOf: fileURL, encoding: .utf8) {
		return script
	}
	return ""
}()

struct HTMLContentView_Previews: View {
	let htmlString = """
<H1> The values and pricinples of the UK </H1>
<p>Although Britain is one of the world's most diverse societies, there is a set of shared values and responsibilities that everyone can agree with. These values and responsibilities include:</p> 
<ul>
	<li>To obey and respect the law</li> 
	<li>To be aware of the rights of others and respect those rights</li> 
	<li>To treat others with fairness</li> 
	<li>To behave responsibly</li> 
	<li>To help and protect your family</li> 
	<li>To respect and preserve the environment</li> 
	<li>To treat everyone equally, regardless of sex, race, religion, age, disability, class or sexual orientation</li> 
	<li>To work to provide for yourself and your family</li> 
	<li>To help others</li> 
	<li>To vote in local and national government elections.</li> 
</ul>

 <p>In return, the UK offers:</p>
 
 <ul>
	 <li>Freedom Of Belief And Religion</li>
	 <li>Freedom Of Speech</li>
	 <li>Freedom From Unfair Discrimination</li>
	 <li>A Right To A Fair Trial</li>
	 <li>A Right To Join In The Election Of A Government</li>
 </ul>

 <p>As part of the citizenship ceremony, new citizens pledge to uphold these values. The pledge is:</p>
 
 <blockquote>'I will give my loyalty to the United Kingdom and respect its rights and freedoms. I will uphold its democratic values. I will observe its laws faithfully and fulfil my duties and obligations as a British citizen.'</blockquote>
 
 <p>Flowing from the fundamental principles are responsibilities and freedoms which are shared by all those living in the UK and which we expect all residents to respect.</p>

"""
//	let font = UIFont.systemFont(ofSize: 18)
	let foregroundColor = UIColor.black
	let shouldResizeToFit = true
	@State private var scrollProgres: Double = .zero
	@StateObject private var highlightManager = HighlightManager()

	var body: some View {
		HTMLView(html: htmlString, chapterId: "Chapter-1", fontSize: .constant(20.0), scrollProgress: $scrollProgres, highlightManager: highlightManager)
	}
}

struct HTMLView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationStack {
			HTMLContentView_Previews()
		}
    }
}
