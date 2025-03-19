
//
//  HighlighterScript.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 15/03/2025.
//


// Track if a highlight is in progress to avoid double processing
let isHighlightInProgress = false;

// Generate a unique ID for each highlight
function generateUUID() {
	return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
		let r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
		return v.toString(16);
	});
}

// Create a highlight menu
function createHighlightMenu() {
	const menu = document.createElement('div');
	menu.className = 'highlight-menu';
	menu.id = 'highlightMenu';

	// Create color buttons
	const colors = [
		{ class: 'yellow', name: 'yellow' },
		{ class: 'green', name: 'green' },
		{ class: 'blue', name: 'blue' },
		{ class: 'pink', name: 'pink' }
	];

	colors.forEach(color => {
		const button = document.createElement('button');
		button.className = color.class;
		button.onclick = function() { highlightSelection(color.name); };
		menu.appendChild(button);
	});

	return menu;
}

// Position the highlight menu near the selection
function positionHighlightMenu(selection) {
	const menu = document.getElementById('highlightMenu');
	if (!menu) return;

	const range = selection.getRangeAt(0);
	const rect = range.getBoundingClientRect();

	// Position above the selection
	menu.style.top = (window.scrollY + rect.top - menu.offsetHeight - 100) + 'px';
	menu.style.left = (window.scrollX + rect.left + (rect.width / 2) - (menu.offsetWidth / 2)) + 'px';

	// Make sure the menu is visible
	document.body.appendChild(menu);
}

// Remove the highlight menu
function removeHighlightMenu() {
	const menu = document.getElementById('highlightMenu');
	if (menu && menu.parentNode) {
		menu.parentNode.removeChild(menu);
	}
}

// Create a span with highlight styling
function createHighlightSpan(color, id) {
	const span = document.createElement('span');
	span.className = 'highlighted highlight-' + color;
	span.setAttribute('data-highlight-id', id);
	return span;
}

// Highlight the selected text
function highlightSelection(color) {

	window.webkit.messageHandlers.debugHandler.postMessage({"Started highlightSelection", color: color})
	if (isHighlightInProgress) {
		window.webkit.messageHandlers.debugHandler.postMessage({"Highlight in progress, exit"})
		return;
	}
	isHighlightInProgress = true;
	window.webkit.messageHandlers.debugHandler.postMessage({"getSelection()"})

	const selection = window.getSelection();
	window.webkit.messageHandlers.debugHandler.postMessage({"got text selection", text: selection})

	if (selection.rangeCount === 0) {
		isHighlightInProgress = false;
		return;
	}

	const range = selection.getRangeAt(0);
	if (range.collapsed) {
		isHighlightInProgress = false;
		return;
	}

	// Create a unique ID for this highlight
	const highlightId = generateUUID();

	// Create a highlighted span
	const highlightSpan = createHighlightSpan(color, highlightId);

	// Apply the highlight
	range.surroundContents(highlightSpan);

	// Get the highlighted text
	const text = highlightSpan.textContent;

	// Calculate text offsets (for future reference)
	const bodyText = document.body.textContent;
	const startOffset = bodyText.indexOf(text);
	const endOffset = startOffset + text.length;

	// Send highlight data to Swift
	window.webkit.messageHandlers.highlightHandler.postMessage({
		type: 'addHighlight',
		highlightId: highlightId,
		text: text,
		startOffset: startOffset,
		endOffset: endOffset,
		color: color
	});

	// Clean up
	removeHighlightMenu();
	selection.removeAllRanges();
	isHighlightInProgress = false;

	// Add context menu for this highlight
	highlightSpan.addEventListener('contextmenu', function(e) {
		e.preventDefault();
		showHighlightContextMenu(e, highlightId);
		return false;
	});
}

// Show context menu for existing highlight
function showHighlightContextMenu(event, highlightId) {
	// Create a context menu for removing highlights
	const contextMenu = document.createElement('div');
	contextMenu.className = 'highlight-menu';
	contextMenu.id = 'contextMenu';

	// Add remove button
	const removeButton = document.createElement('button');
	removeButton.className = 'remove';
	removeButton.innerHTML = '×';
	removeButton.onclick = function() { removeHighlight(highlightId); };
	contextMenu.appendChild(removeButton);

	// Position the menu at the click location
	contextMenu.style.top = (window.scrollY + event.clientY - 40) + 'px';
	contextMenu.style.left = (window.scrollX + event.clientX - 15) + 'px';

	// Add to document
	document.body.appendChild(contextMenu);

	// Close the context menu when clicking elsewhere
	setTimeout(() => {
		document.addEventListener('click', function closeMenu(e) {
			if (!contextMenu.contains(e.target)) {
				document.body.removeChild(contextMenu);
				document.removeEventListener('click', closeMenu);
			}
		});
	}, 10);
}

// Remove a highlight
function removeHighlight(highlightId) {
	const highlightSpan = document.querySelector(`[data-highlight-id="${highlightId}"]`);
	if (highlightSpan) {
		// Replace the span with its text content
		const parent = highlightSpan.parentNode;
		const text = document.createTextNode(highlightSpan.textContent);
		parent.replaceChild(text, highlightSpan);

		// Notify Swift
		window.webkit.messageHandlers.highlightHandler.postMessage({
			type: 'removeHighlight',
			highlightId: highlightId
		});

		// Remove any open context menu
		const contextMenu = document.getElementById('contextMenu');
		if (contextMenu) {
			contextMenu.parentNode.removeChild(contextMenu);
		}
	}
}

// Apply saved highlights
function applyHighlights(highlightsJSON) {
	const highlights = JSON.parse(highlightsJSON);

	for (const highlight of highlights) {
		try {
			// Find occurrence of this highlight text in the document
			const textNodes = [];
			const walker = document.createTreeWalker(
				document.body,
				NodeFilter.SHOW_TEXT,
				null,
				false
			);

			let node;
			while (node = walker.nextNode()) {
				const content = node.textContent;
				if (content.includes(highlight.text)) {
					textNodes.push(node);
				}
			}

			// Find the right text node with the closest offset to our saved highlight
			if (textNodes.length > 0) {
				// Get body text to match offsets
				const bodyText = document.body.textContent;
				let closestNode = textNodes[0];
				let minDistance = Number.MAX_SAFE_INTEGER;

				for (const node of textNodes) {
					const nodeText = node.textContent;
					const nodeStart = bodyText.indexOf(nodeText);
					const distance = Math.abs(nodeStart - highlight.startOffset);

					if (distance < minDistance) {
						minDistance = distance;
						closestNode = node;
					}
				}

				// Find the position of the highlight text in the node
				const nodeText = closestNode.textContent;
				const index = nodeText.indexOf(highlight.text);

				if (index !== -1) {
					// Create a range for this text
					const range = document.createRange();
					range.setStart(closestNode, index);
					range.setEnd(closestNode, index + highlight.text.length);

					// Create a highlight span
					const highlightSpan = createHighlightSpan(highlight.color, highlight.highlightId);

					// Apply the highlight
					range.surroundContents(highlightSpan);

					// Add context menu for this highlight
					highlightSpan.addEventListener('contextmenu', function(e) {
						e.preventDefault();
						showHighlightContextMenu(e, highlight.highlightId);
						return false;
					});
				}
			}
		} catch (error) {
			console.error('Error applying highlight:', error);
		}
	}
}

// Set up text selection handling
document.addEventListener('selectionchange', function() {
	// Remove any existing highlight menu
	removeHighlightMenu();

	const selection = window.getSelection();
	if (selection.rangeCount === 0 || selection.toString().trim() === '') {
		return;
	}

	// Check if selection is inside an existing highlight
	const anchorNode = selection.anchorNode;
	if (anchorNode && anchorNode.parentNode) {
		const parent = anchorNode.parentNode;
		if (parent.classList && parent.classList.contains('highlighted')) {
			return; // Don't show highlight menu for existing highlights
		}
	}

	// Only show menu if text is selected
	if (!selection.isCollapsed && selection.toString().trim() !== '') {
		// Create and position the highlight menu
		const menu = createHighlightMenu();
		document.body.appendChild(menu);
		positionHighlightMenu(selection);
	}
});

// Hide the highlight menu when clicking elsewhere
document.addEventListener('click', function(e) {
	const menu = document.getElementById('highlightMenu');
	if (menu && !menu.contains(e.target)) {
		removeHighlightMenu();
	}
});

document.addEventListener("DOMContentLoaded", function () {
	document.addEventListener('touchstart', function(e) {
		// This prevents the native selection menu from appearing
		document.documentElement.style.webkitUserSelect = 'none';
		document.documentElement.style.webkitTouchCallout = 'none';
	}, false);

	document.addEventListener('touchend', function(e) {
		// Re-enable text selection after the touch ends
		document.documentElement.style.webkitUserSelect = 'text';
		document.documentElement.style.webkitTouchCallout = 'default';

		//		// Small delay to allow our custom selection to work
		//		setTimeout(function() {
		//			const selection = window.getSelection();
		//			if (!selection.isCollapsed && selection.toString().trim() !== '') {
		//				// Create and position our custom menu
		//				const menu = createHighlightMenu();
		//				document.body.appendChild(menu);
		//				positionHighlightMenu(selection);
		//
		//				// Prevent default context menu
		//				e.preventDefault();
		//				return false;
		//			}
		//		}, 100);
		//	}, false);

		let touch = event.changedTouches[0];
		let x = touch.clientX;
		let y = touch.clientY;

		let range = document.caretRangeFromPoint(x, y);
		if (!range) return;

		let selectedWord = getWordAtRange(range);
		if (selectedWord) {
			window.webkit.messageHandlers.debugHandler.postMessage({"got selected text", text: selectedWord})
			window.webkit.messageHandlers.highlightHandler.postMessage(selectedWord);
		}
	});
});

function getWordAtRange(range) {
	let startOffset = range.startOffset;
	let textNode = range.startContainer;

	if (!textNode || textNode.nodeType !== Node.TEXT_NODE) return null;

	let text = textNode.textContent;
	let start = startOffset, end = startOffset;

	while (start > 0 && /\w/.test(text[start - 1])) start--; // Move left
	while (end < text.length && /\w/.test(text[end])) end++; // Move right

	return text.substring(start, end);
}

function getSelectionAndSendMessage()
{
	var txt = document.getSelection().toString() ;
	window.webkit.messageHandlers.newSelectionDetected.postMessage(txt);
}
document.onmouseup = getSelectionAndSendMessage;
document.onkeyup = getSelectionAndSendMessage;
document.oncontextmenu = getSelectionAndSendMessage;
