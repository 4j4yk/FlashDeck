import SwiftUI

struct StudyView: View {
    @EnvironmentObject private var reviewStore: ReviewStore

    let session: StudySession
    private let cardAssistService: any CardAssistService
    @ScaledMetric(relativeTo: .title2) private var cardMinHeight = 492

    @State private var currentIndex: Int
    @State private var orderedCards: [FlashCard]
    @State private var isFlipped = false
    @State private var isShuffled = false
    @State private var dragOffset: CGFloat = 0
    @State private var assistPresentation: AssistPresentation?
    @State private var assistSheetPresentation: AssistPresentation?
    @State private var assistTask: Task<Void, Never>?

    init(session: StudySession, cardAssistService: any CardAssistService = GroundedCardAssistService.shared) {
        self.session = session
        self.cardAssistService = cardAssistService
        let clampedIndex = min(max(session.startIndex, 0), max(session.cards.count - 1, 0))
        _currentIndex = State(initialValue: clampedIndex)
        _orderedCards = State(initialValue: session.cards)
    }

    private var currentCard: FlashCard? {
        guard orderedCards.indices.contains(currentIndex) else { return nil }
        return orderedCards[currentIndex]
    }

    private var progressText: String {
        guard orderedCards.isEmpty == false else { return "0 / 0" }
        return "\(currentIndex + 1) / \(orderedCards.count)"
    }

    private var progressValue: Double {
        guard orderedCards.isEmpty == false else { return 0 }
        return Double(currentIndex + 1) / Double(orderedCards.count)
    }

    private var progressPercentText: String {
        "\(Int((progressValue * 100).rounded()))%"
    }

    private var dragProgress: CGFloat {
        min(abs(dragOffset) / 160, 1)
    }

    private var canMoveForward: Bool {
        currentIndex < orderedCards.count - 1
    }

    private var canMoveBackward: Bool {
        currentIndex > 0
    }

    var body: some View {
        ZStack {
            AppBackground(accentDeck: session.deckCategory)

            if let currentCard {
                VStack(spacing: 22) {
                    header
                    assistPanel

                    FlipFlashCardView(
                        card: currentCard,
                        deckID: session.deckCategory,
                        isMarked: reviewStore.isMarked(currentCard.id),
                        onToggle: toggleCardFace,
                        isFlipped: $isFlipped
                    )
                    .id(currentCard.id)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: cardMinHeight)
                    .offset(x: dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset / 18)))
                    .scaleEffect(1 - (dragProgress * 0.035))
                    .animation(.interactiveSpring(response: 0.26, dampingFraction: 0.86), value: dragOffset)
                    .highPriorityGesture(dragGesture)
                    .padding(.horizontal, 20)
                    .accessibilityHint("Double tap to flip the card. Use Actions for next or previous card.")
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment:
                            moveNext()
                        case .decrement:
                            movePrevious()
                        @unknown default:
                            break
                        }
                    }
                    .accessibilityAction(named: Text("Next Card")) {
                        moveNext()
                    }
                    .accessibilityAction(named: Text("Previous Card")) {
                        movePrevious()
                    }

                    reviewButton(for: currentCard)
                }
                .padding(.top, 16)
                .padding(.bottom, 30)
            } else {
                EmptyStateView(
                    symbolName: "rectangle.stack.badge.minus",
                    title: "No cards available",
                    message: "Open a deck from the browser and start a study session there."
                )
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle(session.deckTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if let currentCard {
                    Menu {
                        Button(isFlipped ? "Show Question" : "Show Answer") {
                            toggleCardFace()
                        }

                        if canMoveBackward {
                            Button("Previous Card") {
                                movePrevious()
                            }
                        }

                        if canMoveForward {
                            Button("Next Card") {
                                moveNext()
                            }
                        }

                        Button(reviewStore.isMarked(currentCard.id) ? "Unmark Review" : "Mark for Review") {
                            reviewStore.toggle(currentCard.id)
                            Haptics.selection()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Card actions")
                }

                if orderedCards.count > 1 {
                    Button {
                        toggleShuffle()
                    } label: {
                        Image(systemName: isShuffled ? "shuffle.circle.fill" : "shuffle.circle")
                    }
                    .accessibilityLabel(isShuffled ? "Disable shuffle" : "Enable shuffle")
                }
            }
        }
        .sheet(isPresented: assistSheetIsPresented) {
            if let assistSheetPresentation {
                NavigationStack {
                    AssistPanelView(presentation: assistSheetPresentation)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    self.assistSheetPresentation = nil
                                }
                            }
                        }
                }
                .presentationDetents([.medium, .large])
            }
        }
        .onChange(of: currentCard?.id) { _, _ in
            assistTask?.cancel()
            assistPresentation = nil
            assistSheetPresentation = nil
        }
        .onDisappear {
            assistTask?.cancel()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 7) {
                    Text(session.mode.title.uppercased())
                        .font(.system(.caption2, design: .rounded).weight(.bold))
                        .foregroundStyle(AppTheme.tertiaryText)

                    Text(session.mode.detailText(cardCount: orderedCards.count))
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(AppTheme.primaryText)

                    Text("Tap the card to flip. Swipe sideways to move, or use Actions.")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(progressPercentText)
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(AppTheme.primaryText)

                    Text(progressText)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(minWidth: 74)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.surfaceGradient)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.outlineGradient, lineWidth: 1)
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Session progress")
                .accessibilityValue("\(progressText). \(progressPercentText)")
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.secondarySurface)
                        .overlay(
                            Capsule()
                                .stroke(AppTheme.line, lineWidth: 1)
                        )

                    Capsule()
                        .fill(AppTheme.gradient(for: session.deckCategory))
                        .frame(width: progressWidth(totalWidth: proxy.size.width))
                }
            }
            .frame(height: 8)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Progress bar")
            .accessibilityValue(progressPercentText)
        }
        .padding(.horizontal, 20)
    }

    private var assistPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(CardAssistAction.allCases) { action in
                        Button {
                            presentAssist(action)
                        } label: {
                            Label(action.title, systemImage: action.systemImage)
                                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                .foregroundStyle(AppTheme.primaryText)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(AppTheme.surfaceGradient)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(AppTheme.outlineGradient, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(action.title)
                        .accessibilityHint("Uses local deck knowledge for the current card.")
                    }
                }
                .padding(.horizontal, 1)
            }
            .scrollClipDisabled()

            switch assistPresentation?.state {
            case .loading:
                HStack(spacing: 10) {
                    ProgressView()
                        .controlSize(.small)

                    Text("Grounding help from local deck knowledge.")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(AppTheme.secondaryText)
                }

            case let .response(response):
                HStack(spacing: 10) {
                    Text(response.groundingLabel.uppercased())
                        .font(.system(.caption2, design: .rounded).weight(.bold))
                        .foregroundStyle(AppTheme.tertiaryText)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(AppTheme.secondarySurface, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(AppTheme.line, lineWidth: 1)
                        )

                    Text(response.headline)
                        .font(.system(.footnote, design: .rounded).weight(.semibold))
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineLimit(1)
                }

            case nil:
                Text("Explain, compare, quiz, or review the current card using local deck knowledge.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .padding(.horizontal, 20)
        .accessibilityElement(children: .contain)
    }

    private var assistSheetIsPresented: Binding<Bool> {
        Binding(
            get: { assistSheetPresentation != nil },
            set: { isPresented in
                if isPresented == false {
                    assistSheetPresentation = nil
                }
            }
        )
    }

    private func reviewButton(for card: FlashCard) -> some View {
        Button {
            reviewStore.toggle(card.id)
            Haptics.selection()
        } label: {
            Label(
                reviewStore.isMarked(card.id) ? "Marked for review" : "Mark for review",
                systemImage: reviewStore.isMarked(card.id) ? "bookmark.fill" : "bookmark"
            )
            .font(.system(.headline, design: .rounded).weight(.semibold))
            .foregroundStyle(reviewStore.isMarked(card.id) ? .white : AppTheme.primaryText)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        reviewStore.isMarked(card.id)
                            ? AnyShapeStyle(AppTheme.gradient(for: session.deckCategory))
                            : AnyShapeStyle(AppTheme.surfaceGradient)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(reviewStore.isMarked(card.id) ? 0.14 : 0.18), lineWidth: 1)
            )
            .shadow(color: AppTheme.shadowColor.opacity(0.42), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityValue(reviewStore.isMarked(card.id) ? "Marked" : "Not marked")
        .padding(.horizontal, 20)
    }

    private func presentAssist(_ action: CardAssistAction) {
        guard let card = currentCard else { return }

        let request = CardAssistRequest(
            action: action,
            deckID: session.deckID,
            deckTitle: session.deckTitle,
            deckCategory: session.deckCategory,
            deckCards: orderedCards,
            cardID: card.id,
            cardTitle: card.title,
            prompt: card.prompt,
            answer: card.answer,
            tags: card.tags,
            userInput: nil
        )

        assistTask?.cancel()
        let loadingPresentation = AssistPresentation.loading(for: request)
        assistPresentation = loadingPresentation
        assistSheetPresentation = loadingPresentation

        assistTask = Task {
            let response = await cardAssistService.respond(to: request)
            guard Task.isCancelled == false else { return }

            await MainActor.run {
                guard currentCard?.id == request.cardID else { return }
                let responsePresentation = AssistPresentation(response: response, cardTitle: request.cardTitle)
                assistPresentation = responsePresentation

                if assistSheetPresentation != nil {
                    assistSheetPresentation = responsePresentation
                }
            }
        }

        Haptics.soft(0.44)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 24)
            .onChanged { value in
                let translation = value.translation.width
                let isAtEdge = (translation < 0 && canMoveForward == false) || (translation > 0 && canMoveBackward == false)
                dragOffset = isAtEdge ? translation * 0.28 : translation * 0.92
            }
            .onEnded { value in
                let projected = value.predictedEndTranslation.width
                let resolved = abs(projected) > abs(value.translation.width) ? projected : value.translation.width
                let threshold: CGFloat = 72

                if resolved <= -threshold {
                    moveNext()
                } else if resolved >= threshold {
                    movePrevious()
                } else {
                    withAnimation(.interactiveSpring(response: 0.24, dampingFraction: 0.84)) {
                        dragOffset = 0
                    }
                    Haptics.soft(0.34)
                }
            }
    }

    private func toggleCardFace() {
        withAnimation(.interactiveSpring(response: 0.48, dampingFraction: 0.84, blendDuration: 0.14)) {
            isFlipped.toggle()
        }
        Haptics.soft(0.66)
    }

    private func moveNext() {
        guard canMoveForward else { return }
        withAnimation(.interactiveSpring(response: 0.30, dampingFraction: 0.84)) {
            currentIndex += 1
            isFlipped = false
            dragOffset = 0
        }
        Haptics.light(0.62)
    }

    private func movePrevious() {
        guard canMoveBackward else { return }
        withAnimation(.interactiveSpring(response: 0.30, dampingFraction: 0.84)) {
            currentIndex -= 1
            isFlipped = false
            dragOffset = 0
        }
        Haptics.light(0.62)
    }

    private func toggleShuffle() {
        let currentCardID = currentCard?.id

        withAnimation(.interactiveSpring(response: 0.34, dampingFraction: 0.86)) {
            isShuffled.toggle()
            orderedCards = isShuffled ? session.cards.shuffled() : session.cards

            if let currentCardID,
               let newIndex = orderedCards.firstIndex(where: { $0.id == currentCardID }) {
                currentIndex = newIndex
            } else {
                currentIndex = min(currentIndex, max(orderedCards.count - 1, 0))
            }

            isFlipped = false
        }

        Haptics.soft(0.56)
    }

    private func progressWidth(totalWidth: CGFloat) -> CGFloat {
        guard orderedCards.isEmpty == false else { return 0 }
        return totalWidth * CGFloat(currentIndex + 1) / CGFloat(orderedCards.count)
    }
}

struct StudyView_Previews: PreviewProvider {
    static var previews: some View {
        let reviewStore = ReviewStore()

        return NavigationStack {
            StudyView(
                session: StudySession(
                    deckID: DeckCategory.systemDesign.rawValue,
                    deckTitle: "System Design",
                    deckCategory: .systemDesign,
                    mode: .randomTwenty,
                    cards: Array(SystemDesignDeck.cards.prefix(12)),
                    startIndex: 0
                )
            )
                .environmentObject(reviewStore)
        }
    }
}

private struct AssistPresentation: Identifiable {
    enum State {
        case loading
        case response(CardAssistResponse)
    }

    let id: String
    let action: CardAssistAction
    let cardTitle: String
    let state: State

    init(id: String, action: CardAssistAction, cardTitle: String, state: State) {
        self.id = id
        self.action = action
        self.cardTitle = cardTitle
        self.state = state
    }

    static func loading(for request: CardAssistRequest) -> AssistPresentation {
        AssistPresentation(
            id: request.cacheKey,
            action: request.action,
            cardTitle: request.cardTitle,
            state: .loading
        )
    }

    init(response: CardAssistResponse, cardTitle: String) {
        self.id = response.id
        self.action = response.action
        self.cardTitle = cardTitle
        self.state = .response(response)
    }
}

private struct AssistPanelView: View {
    let presentation: AssistPresentation

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text(presentation.action.title.uppercased())
                    .font(.system(.caption2, design: .rounded).weight(.bold))
                    .foregroundStyle(AppTheme.tertiaryText)

                Text(presentation.cardTitle)
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .foregroundStyle(AppTheme.primaryText)

                switch presentation.state {
                case .loading:
                    VStack(alignment: .leading, spacing: 14) {
                        ProgressView()
                            .controlSize(.regular)

                        Text("Preparing offline help for this card.")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .padding(.top, 10)

                case let .response(response):
                        VStack(alignment: .leading, spacing: 16) {
                            if response.groundingLabel.isEmpty == false {
                                Text(response.groundingLabel.uppercased())
                                    .font(.system(.caption2, design: .rounded).weight(.bold))
                                    .foregroundStyle(AppTheme.tertiaryText)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(AppTheme.secondarySurface, in: Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(AppTheme.line, lineWidth: 1)
                                    )
                            }

                            Text(response.headline)
                                .font(.system(.headline, design: .rounded).weight(.semibold))
                                .foregroundStyle(AppTheme.primaryText)

                        Text(response.summary)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(AppTheme.primaryText)
                            .lineSpacing(3)

                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(response.bullets.enumerated()), id: \.offset) { _, bullet in
                                HStack(alignment: .top, spacing: 10) {
                                    Circle()
                                        .fill(AppTheme.accentColor(for: .custom))
                                        .frame(width: 8, height: 8)
                                        .padding(.top, 7)

                                    Text(bullet)
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundStyle(AppTheme.secondaryText)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }

                        if response.snippets.isEmpty == false {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Deck References")
                                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                    .foregroundStyle(AppTheme.primaryText)

                                ForEach(response.snippets) { snippet in
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(snippet.title)
                                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                            .foregroundStyle(AppTheme.primaryText)

                                        Text(snippet.detail)
                                            .font(.system(.footnote, design: .rounded))
                                            .foregroundStyle(AppTheme.secondaryText)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .padding(14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(AppTheme.surfaceGradient)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(AppTheme.outlineGradient, lineWidth: 1)
                                    )
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text(response.footer)
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(AppTheme.secondaryText)

                            Text(response.sourceLabel)
                                .font(.system(.caption, design: .rounded).weight(.semibold))
                                .foregroundStyle(AppTheme.tertiaryText)
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .padding(24)
        }
        .background(AppBackground(accentDeck: .custom))
        .navigationTitle("Card Assist")
        .navigationBarTitleDisplayMode(.inline)
    }
}
