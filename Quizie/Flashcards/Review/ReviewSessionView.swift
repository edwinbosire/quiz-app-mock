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
                        readyView(viewModel)
                    }
                case .reviewing:
                    if let viewModel {
                        reviewingView(viewModel)
                    }
                case .complete:
                    if let viewModel {
                        completeView(viewModel)
                    }
                case .empty:
                    emptyView
                case .error:
                    errorView
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

    @ViewBuilder
    private func readyView(_ viewModel: ReviewSessionViewModel) -> some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Text("Review Session")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("\(viewModel.cardCount) cards")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("~\(viewModel.estimatedMinutes) minutes")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Button {
                viewModel.startSession()
            } label: {
                Text("Start")
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

    @ViewBuilder
    private func reviewingView(_ viewModel: ReviewSessionViewModel) -> some View {
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

    @ViewBuilder
    private func completeView(_ viewModel: ReviewSessionViewModel) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Session Complete")
                .font(.largeTitle)
                .fontWeight(.bold)

            if let summary = viewModel.summary {
                VStack(spacing: 16) {
                    statRow(label: "Cards reviewed", value: "\(summary.totalCards)")
                    statRow(label: "Time", value: summary.formattedDuration)

                    Divider()
                        .padding(.vertical, 8)

                    HStack(spacing: 24) {
                        miniStat(emoji: Difficulty.again.emoji, count: summary.againCount, color: .red)
                        miniStat(emoji: Difficulty.hard.emoji, count: summary.hardCount, color: .orange)
                        miniStat(emoji: Difficulty.good.emoji, count: summary.goodCount, color: .green)
                        miniStat(emoji: Difficulty.easy.emoji, count: summary.easyCount, color: .blue)
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

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }

    private func miniStat(emoji: String, count: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.title2)
            Text("\(count)")
                .font(.headline)
                .foregroundStyle(color)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Text("All done for today!")
                .font(.title)
                .fontWeight(.bold)

            Text("You've reviewed all your due cards.")
                .foregroundStyle(.secondary)

            Button {
                router.navigateBack()
            } label: {
                Text("Go Back")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top)
        }
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            Text("Something went wrong")
                .font(.headline)

            Button("Try Again") {
                Task {
                    await viewModel?.loadDueCards()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ReviewSessionView()
    }
    .environment(Router(isPresented: .constant(nil)))
}
