import SwiftUI

struct FlashcardsHomeView: View {
    @Environment(Router.self) private var router
    @State private var viewModel: FlashcardsHomeViewModel?
    @State private var viewState: FlashcardsHomeViewModel.ViewState = .loading

    var body: some View {
        ZStack {
            PastelTheme.background
                .ignoresSafeArea()

            Group {
                switch viewState {
                case .loading:
                    ProgressView()
                case .content:
                    if let viewModel {
                        contentView(viewModel)
                    }
                case .empty:
                    emptyStateView
                case .error:
                    errorView
                }
            }
        }
		.toolbarColorScheme(.dark, for: .navigationBar)
        .navigationTitle("Flashcards")
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button(role: .none) {
					router.navigate(to: .flashcardCreate, navigationType: .sheet)

				} label: {
					Image(systemName: "plus")
						.foregroundStyle(Color.white)
						.fontWeight(.bold)

				}
			}
		}
        .task {
            viewModel = await FlashcardsHomeViewModel.viewDidLoad()
            if let viewModel {
                viewState = viewModel.viewState
            }
        }
        .onChange(of: viewModel?.viewState) { _, newValue in
            if let newValue {
                viewState = newValue
            }
        }
        .refreshable {
            await viewModel?.loadStats()
        }
    }

    @ViewBuilder
    private func contentView(_ viewModel: FlashcardsHomeViewModel) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                dueCardSection(viewModel)

                progressSection(viewModel)

                actionButtonsSection
            }
            .padding()
        }
    }

    @ViewBuilder
    private func dueCardSection(_ viewModel: FlashcardsHomeViewModel) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.orange)
                Text("Due Today")
                    .font(.headline)
                Spacer()
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.dueCardsCount)")
                        .font(.system(size: 48, weight: .bold))

                    if viewModel.hasDueCards {
                        Text("~\(viewModel.estimatedReviewMinutes) min")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("All caught up!")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }
                }

                Spacer()

                if viewModel.hasDueCards {
                    Button {
                        router.navigate(to: .flashcardsReview, navigationType: .push)
                    } label: {
                        Text("Start Review")
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8)
    }

    @ViewBuilder
    private func progressSection(_ viewModel: FlashcardsHomeViewModel) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.blue)
                Text("Progress")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(viewModel.streak)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Text("Day Streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .frame(height: 40)

                VStack(spacing: 4) {
                    Text("\(viewModel.masteredCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Mastered")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .frame(height: 40)

                VStack(spacing: 4) {
                    Text("\(viewModel.totalCardsCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Total Cards")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8)
    }

    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            actionButton(
                icon: "plus.circle.fill",
                title: "New Card",
                color: .green
            ) {
                router.navigate(to: .flashcardCreate, navigationType: .sheet)
            }

            actionButton(
                icon: "rectangle.stack.fill",
                title: "Browse All Cards",
                color: .purple
            ) {
                router.navigate(to: .flashcardsBrowse, navigationType: .push)
            }
        }
    }

    private func actionButton(
        icon: String,
        title: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
                Text(title)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No flashcards yet")
                .font(.title2)
                .fontWeight(.bold)

            Text("Bookmark questions during exams\nor create your own.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button {
                router.navigate(to: .flashcardCreate, navigationType: .sheet)
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Create First Card")
                }
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top)
        }
		.foregroundStyle(Color.white)
        .padding()
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
                    await viewModel?.loadStats()
                }
            }
        }
		.foregroundStyle(Color.white)

    }
}

#Preview {
    NavigationStack {
        FlashcardsHomeView()
    }
    .environment(Router(isPresented: .constant(nil)))
}
