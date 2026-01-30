//
//  WebViewCoordinator.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 15/03/2025.
//

import Foundation
import WebKit
// WKWebView coordinator to handle JavaScript communication
class WebViewCoordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate, UIScrollViewDelegate {
	var parent: HTMLView

	init(_ parent: HTMLView) {
		self.parent = parent
		super.init()
	}

	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		print("didReceive: \(message.name) - \(message.body)")
		if message.name == "highlightHandler" {
			guard let dict = message.body as? [String: Any],
				  let type = dict["type"] as? String else {
				return
			}

			if type == "addHighlight" {
				guard let highlightId = dict["highlightId"] as? String,
					  let text = dict["text"] as? String,
					  let startOffset = dict["startOffset"] as? Int,
					  let endOffset = dict["endOffset"] as? Int,
					  let color = dict["color"] as? String else {
					return
				}

				let highlight = TextHighlight(
					chapterId: parent.chapterId,
					highlightId: highlightId,
					text: text,
					startOffset: startOffset,
					endOffset: endOffset,
					color: color,
					timestamp: Date()
				)

				parent.highlightManager.addHighlight(highlight)
			} else if type == "removeHighlight" {
				if let highlightId = dict["highlightId"] as? String {
					parent.highlightManager.removeHighlight(id: highlightId)
				}
			}
		}
	}

	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		// Apply saved highlights after page loads
		webView.evaluateJavaScript("document.body.setAttribute('oncontextmenu', 'event.preventDefault();');", completionHandler:nil);
		let highlights = parent.highlightManager.getHighlightsForChapter(chapterId: parent.chapterId)

		if !highlights.isEmpty {
			// Convert highlights to JSON string
			if let highlightsData = try? JSONEncoder().encode(highlights),
			   let highlightsString = String(data: highlightsData, encoding: .utf8) {
				// Escape quotes for JavaScript
				let escapedHighlights = highlightsString.replacingOccurrences(of: "\"", with: "\\\"")

				// Apply highlights using JavaScript
				let script = "applyHighlights(\"\(escapedHighlights)\");"
				webView.evaluateJavaScript(script, completionHandler: nil)
			}
		}
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let contentSize = scrollView.contentSize
		let contentOffset = scrollView.contentOffset

		let progress = (contentOffset.y / (contentSize.height-721))*100
		let scrollProgress = min(100, max(0, progress))
		parent.scrollProgress = scrollProgress
	}

}
