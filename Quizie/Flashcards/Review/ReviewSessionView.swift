import SwiftUI

struct ReviewSessionView: View {
	@Environment(Router.self) private var router
	@State private var viewModel: ReviewSessionViewModel?
	@State private var viewState: ReviewSessionViewModel.ViewState = .loading

	var body: some View {
		ZStack {
			PastelTheme.background
				.ignoresSafeArea()

			Group {
				switch viewState {
					case .loading:
						loadingView
					case .ready:
						if let viewModel {
							ReadyView(viewModel: viewModel)
						}
					case .reviewing:
						if let viewModel {
							ReviewingView(viewModel: viewModel)
						}
					case .complete:
						if let viewModel {
							CompleteView(viewModel: viewModel)
						}
					case .empty:
						FlashcardCardEmptyView()
					case .error:
						FlashcardErrorView(viewModel: viewModel)
				}
			}
		}
		.navigationBarBackButtonHidden(viewState == .reviewing)
		.toolbar {
			if viewState == .reviewing {
				ToolbarItem(placement: .topBarLeading) {
					Button("End") {
						router.navigateBack()
					}
					.foregroundStyle(.secondary)
				}
			}
		}
		.task {
			viewModel = await ReviewSessionViewModel.viewDidLoad()
			if let viewModel {
				viewState = viewModel.viewState
			}
		}
		.onChange(of: viewModel?.viewState) { _, newValue in
			if let newValue {
				viewState = newValue
			}
		}
	}

	private var loadingView: some View {
		VStack(spacing: 16) {
			ProgressView()
			Text("Loading cards...")
				.foregroundStyle(.secondary)
		}
	}

}


struct CompleteView:  View {
	@Environment(Router.self) private var router
	let viewModel: ReviewSessionViewModel

	var body: some View {
		VStack(spacing: 24) {
			Spacer()

			Text("Session Complete")
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundStyle(Color.white)

			if let summary = viewModel.summary {
				VStack(spacing: 16) {
					StatRowView(label: "Cards reviewed", value: "\(summary.totalCards)")
					StatRowView(label: "Time", value: summary.formattedDuration)

					Divider()
						.padding(.vertical, 8)

					HStack(spacing: 24) {
						MiniStatView(emoji: Difficulty.again.emoji, count: summary.againCount, color: .red)
						MiniStatView(emoji: Difficulty.hard.emoji, count: summary.hardCount, color: .orange)
						MiniStatView(emoji: Difficulty.good.emoji, count: summary.goodCount, color: .green)
						MiniStatView(emoji: Difficulty.easy.emoji, count: summary.easyCount, color: .blue)
					}
				}
				.padding()
				.background(Color(.systemBackground))
				.clipShape(RoundedRectangle(cornerRadius: 16))
				.shadow(color: .black.opacity(0.05), radius: 8)
				.padding(.horizontal)
			}

			Spacer()

			Button {
				router.navigateBack()
			} label: {
				Text("Done")
					.font(.headline)
					.frame(maxWidth: .infinity)
					.padding()
					.background(Color.accentColor)
					.foregroundStyle(.white)
					.clipShape(RoundedRectangle(cornerRadius: 16))
			}
			.padding(.horizontal, 32)

			Spacer()
		}
	}
}


struct ReviewingView: View {
	@Environment(Router.self) private var router
	let viewModel: ReviewSessionViewModel

	var body: some View {
		VStack(spacing: 16) {
			ProgressView(value: viewModel.progress)
				.tint(.accentColor)
				.padding(.horizontal)

			Text("\(viewModel.completedCount + 1) of \(viewModel.cardCount)")
				.font(.caption)
				.foregroundStyle(.secondary)

			if let card = viewModel.currentCard {
				FlashcardCardView(
					card: card,
					isFlipped: Binding(
						get: { viewModel.isFlipped },
						set: { viewModel.isFlipped = $0 }
					),
					onRate: { difficulty in
						withAnimation {
							viewModel.rateCurrentCard(difficulty)
						}
					}
				)
				.padding(.horizontal)
				.transition(.asymmetric(
					insertion: .move(edge: .trailing).combined(with: .opacity),
					removal: .move(edge: .leading).combined(with: .opacity)
				))
				.id(card.id)
			}

			Spacer()
		}
		.padding(.top)
	}
}


struct ReadyView: View {
	let viewModel: ReviewSessionViewModel

	var body: some View {
		VStack(spacing: 8) {
			Text("Review Session")
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundStyle(.white)

			HStack {
				Label("\(viewModel.cardCount) cards", systemImage: "mail.stack")
				Spacer()
				Label("~\(viewModel.estimatedMinutes) minutes", systemImage: "clock")
			}
			.font(.headline)
			.foregroundStyle(Color.white.opacity(0.4))
			.padding(.bottom)

			Button {
				viewModel.startSession()
			} label: {
				Text("Start")
					.font(.headline)
					.foregroundStyle(.white)
					.frame(maxWidth: .infinity)
					.padding()
					.background(PastelTheme.background)
					.clipShape(RoundedRectangle(cornerRadius: 16))
			}
		}
		.padding()
		.background(PastelTheme.rowBackground, in: RoundedRectangle(cornerRadius: 12.0))
		.padding()
		.shadow(radius: 5.0)
	}
}


struct FlashcardCardEmptyView: View {
	@Environment(Router.self) private var router

	var body: some View {
		VStack(spacing: 16) {
			ContentUnavailableView {
				Label{
					Text("All done for today!")
				} icon: {
					Image(systemName: "trophy")
						.foregroundStyle(.yellow)
				}
			} description: {
				Text("You've reviewed all your due cards.")
			} actions: {
				Button { router.navigateBack() } label: {
					Label("Go Back", systemImage: "arrow.uturn.backward")
						.font(.headline)
						.foregroundStyle(.white)
						.frame(maxWidth: .infinity)
						.padding()
						.background(PastelTheme.rowBackground)
						.clipShape(RoundedRectangle(cornerRadius: 16))
				}
			}
				.background(PastelTheme.background)
				.foregroundStyle(Color.white)

		}
	}
}


struct FlashcardErrorView: View {
	let viewModel: ReviewSessionViewModel?

	var body: some View {
		VStack(spacing: 16) {
			ContentUnavailableView {
				Label{
					Text("Error loading Flashcards.")
				} icon: {
					Image(systemName: "exclamationmark.triangle")
						.foregroundStyle(.yellow)
				}
			} description: {
				Text("Please try again later")
			} actions: {
				Button {
					Task {
						await viewModel?.loadDueCards()
					}
				} label: {
					Label("Try Again", systemImage: "arrow.trianglehead.clockwise")
						.font(.headline)
						.foregroundStyle(.white)
						.frame(maxWidth: .infinity)
						.padding()
						.background(PastelTheme.rowBackground)
						.clipShape(RoundedRectangle(cornerRadius: 16))
				}
			}
				.background(PastelTheme.background)
				.foregroundStyle(Color.white)

		}
	}
}

#Preview("Review Session") {
	NavigationStack {
		ReviewSessionView()
	}
	.environment(Router(isPresented: .constant(nil)))
}

#Preview("Empty View") {
	FlashcardCardEmptyView()
		.environment(Router(isPresented: .constant(nil)))
}

let repository = FlashcardsRepository()
#Preview("Ready View") {
	@Previewable let viewModel = ReviewSessionViewModel(repository: repository)

	ReadyView(viewModel: viewModel)
		.environment(Router(isPresented: .constant(nil)))
}

#Preview("Error View") {
	@Previewable let viewModel = ReviewSessionViewModel(repository: repository)

	FlashcardErrorView(viewModel: viewModel)
		.environment(Router(isPresented: .constant(nil)))
}

