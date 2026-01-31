import SwiftUI

struct FlashcardsMenuCard: View {
    @Environment(Router.self) var router
    @State private var dueCount: Int = 0
    @State private var streak: Int = 0

    private let repository = FlashcardsRepository.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            SectionHeaderView()
                .containerShape(Rectangle())
                .onTapGesture {
                    router.navigate(to: .flashcardsHome)
                }

            CardContent()
        }
    }

    @ViewBuilder
    func SectionHeaderView() -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Flashcards")
                .bold()
                .font(.title2)
                .foregroundColor(.titleText)

            Spacer()

            Image(systemName: "arrowshape.right.circle.fill")
                .font(.title)
                .foregroundColor(.titleText)
                .foregroundStyle(PastelTheme.title)
        }
        .padding()
    }

    @ViewBuilder
    func CardContent() -> some View {
        Button {
            if dueCount > 0 {
                router.navigate(to: .flashcardsReview)
            } else {
                router.navigate(to: .flashcardsHome)
            }
        } label: {
            HStack(spacing: 20) {
				Spacer()
                DueCardsIndicator()
				Spacer()
                StreakIndicator()
				Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
        }
        .buttonStyle(RaisedButtonStyle(color: Color.indigo))
        .padding(.horizontal)
        .padding(.bottom)
        .task {
            await loadStats()
        }
    }

    @ViewBuilder
    func DueCardsIndicator() -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "rectangle.on.rectangle.angled")
                    .font(.title2)
                Text("\(dueCount)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            Text(dueCount == 0 ? "All caught up!" : "Cards due")
                .font(.subheadline)
                .opacity(0.9)
        }
        .foregroundStyle(.white)
    }

    @ViewBuilder
    func StreakIndicator() -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text("\(streak)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            Text("Day streak")
                .font(.subheadline)
                .opacity(0.9)
        }
        .foregroundStyle(.white)
    }

    private func loadStats() async {
        dueCount = (try? await repository.getCardsDueToday().count) ?? 0
        streak = repository.getCurrentStreak()
    }
}

#Preview {
    FlashcardsMenuCard()
        .background(PastelTheme.background)
        .environment(Router(isPresented: .constant(nil)))
}
