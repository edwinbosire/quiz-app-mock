//
//  Route.swift
//  Life In The UK Prep
//
//  Created by Edwin Bosire on 05/02/2025.
//

import Foundation
import SwiftUI

public enum NavigationType {
	case push
	case sheet
	case fullScreenCover
}

enum Destination: Hashable, Equatable {
	case mainMenu
	case mockTest(Int)
	case resultsView(ExamResultViewModel)
	case handbook
	case handbookChapter(Int)
	case handbookSearch(String)
	case questionbank
	case progressReport
	case progressReportDetail(result: ExamResultViewModel)
	case settings
	case monetization
	// Flashcards
	case flashcardsHome
	case flashcardsReview
	case flashcardCreate
	case flashcardsBrowse
	case flashcardDetail(Flashcard)
}

protocol RouterProtocol: AnyObject {
	func navigate(to destination: Destination, navigationType: NavigationType)
}

@Observable
class Router: RouterProtocol {
	var path: NavigationPath = NavigationPath()
	var destination: Destination = .mainMenu
	var showSheet: Bool = false

	/// Used to present a view using a sheet
	public var presentingSheet: Destination?

	/// Used to present a view using a full screen cover
	public var presentingFullScreenCover: Destination?

	/// Used by presented Router instances to dismiss themselves
	@ObservationIgnored public var isPresented: Binding<Destination?>

	public var isPresenting: Bool {
		presentingSheet != nil || presentingFullScreenCover != nil
	}

	public init(isPresented: Binding<Destination?>) {
		self.isPresented = isPresented
	}

	func navigate(to destination: Destination, navigationType: NavigationType = .push) {
		switch navigationType {
			case .push:
				self.path.append(destination)
			case .sheet:
				presentSheet(destination)
			case .fullScreenCover:
				presentFullScreen(destination)
		}
	}

	func navigateBack() {
		guard !path.isEmpty else { return }
		path.removeLast()
	}

	func popToRoot() {
		path.removeLast(path.count - 1)
	}

	private func presentSheet(_ route: Destination) {
		self.presentingSheet = route
	}

	private func presentFullScreen(_ route: Destination) {
		self.presentingFullScreenCover = route
	}

	// Return the appropriate Router instance based
	// on `NavigationType`
	private func router(routeType: NavigationType) -> Router {
		switch routeType {
			case .push:
				return self
			case .sheet:
				return Router(
					isPresented: Binding(
						get: { self.presentingSheet },
						set: { self.presentingSheet = $0 }
					)
				)
			case .fullScreenCover:
				return Router(
					isPresented: Binding(
						get: { self.presentingFullScreenCover },
						set: { self.presentingFullScreenCover = $0 }
					)
				)
		}
	}

	// Dismisses presented screen or self
	func dismiss() {
		if !path.isEmpty {
			path.removeLast()
		} else if presentingSheet != nil {
			presentingSheet = nil
		} else if presentingFullScreenCover != nil {
			presentingFullScreenCover = nil
		} else {
			isPresented.wrappedValue = nil
		}
	}

}

extension View {
	func fullScreen<V: View>(_ isPresenting: Binding<Bool>, router: Router, @ViewBuilder content: @escaping (Destination) -> V) -> some View {
		modifier(FullScreenModifier(router: router, isPresenting: isPresenting, body: content))
	}

	func sheet<Content>(_ isPresented: Binding<Bool>, router: Router, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping (Destination) -> Content) -> some View where Content : View {
		modifier(SheetScreenModifier(router: router, isPresented: isPresented, body: content))
	}
}

struct FullScreenModifier<V: View>: ViewModifier {
	@Bindable var router: Router
	@Binding var isPresenting: Bool
	let body: (Destination) -> V

	func body(content: Content) -> some View {
		content
			.fullScreenCover(isPresented: $isPresenting, onDismiss: router.dismiss) {
				if let destination = router.presentingFullScreenCover {
					body(destination)
				}
			}
	}
}

struct SheetScreenModifier<V: View>: ViewModifier {
	@Bindable var router: Router
	@Binding var isPresented: Bool
	let body: (Destination) -> V

	func body(content: Content) -> some View {
		content
			.sheet(isPresented: $isPresented, onDismiss: router.dismiss) {
				if let destination = router.presentingSheet {
					body(destination)
				}
			}
	}
}
