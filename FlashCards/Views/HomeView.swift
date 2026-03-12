import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var appearanceStore: AppearanceStore

    private let maxImportBytes = 2_000_000

    @State private var isImportingDeck = false
    @State private var isImportingKnowledge = false
    @State private var isExportingDeck = false
    @State private var isShowingAbout = false
    @State private var isShowingAppearance = false
    @State private var exportDocument: DeckFileDocument?
    @State private var exportFilename = "deck"
    @State private var transferNotice: TransferNotice?

    private var lastOpenedAccentDeck: DeckCategory? {
        guard let lastOpenedDeckID = appViewModel.lastOpenedDeckID else { return nil }
        return appViewModel.deck(for: lastOpenedDeckID)?.category
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(accentDeck: lastOpenedAccentDeck)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        hero

                        if let lastDeckID = appViewModel.lastOpenedDeckID,
                           let deck = appViewModel.deck(for: lastDeckID) {
                            SectionHeader(title: "Continue")

                            NavigationLink {
                                DeckBrowserView(deckID: deck.id)
                            } label: {
                                DeckCardView(
                                    deck: deck,
                                    markedCount: appViewModel.markedCount(in: deck.id),
                                    isContinue: true
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        SectionHeader(title: "Decks")

                        VStack(spacing: 18) {
                            ForEach(appViewModel.decks) { deck in
                                NavigationLink {
                                    DeckBrowserView(deckID: deck.id)
                                } label: {
                                    DeckCardView(
                                        deck: deck,
                                        markedCount: appViewModel.markedCount(in: deck.id),
                                        isContinue: false
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        NavigationLink {
                            MarkedCardsView()
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(AppTheme.accentChromeFill)

                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(AppTheme.accentChromeStroke, lineWidth: 1)

                                    Image(systemName: "bookmark.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundStyle(.white)
                                }
                                .frame(width: 58, height: 58)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("FOCUSED REVIEW")
                                        .font(.system(.caption2, design: .rounded).weight(.bold))
                                        .foregroundStyle(.white.opacity(0.70))

                                    Text("Marked for Review")
                                        .font(.system(.title3, design: .rounded).weight(.bold))
                                        .foregroundStyle(.white)

                                    Text("Jump into the cards you want to revisit next.")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.80))
                                }

                                Spacer()

                                ZStack {
                                    Circle()
                                        .fill(AppTheme.accentChromeFill)
                                    Circle()
                                        .stroke(AppTheme.accentChromeStroke, lineWidth: 1)
                                    Text("\(appViewModel.totalMarkedCount())")
                                        .font(.system(.title3, design: .rounded).weight(.bold))
                                        .foregroundStyle(.white)
                                }
                                .frame(width: 52, height: 52)
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 0.21, green: 0.25, blue: 0.35), Color(red: 0.34, green: 0.42, blue: 0.56)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(alignment: .topTrailing) {
                                        if AppTheme.usesAmbientGlow {
                                            Circle()
                                                .fill(AppTheme.ambientHighlight)
                                                .frame(width: 150, height: 150)
                                                .blur(radius: 24)
                                                .offset(x: 42, y: -42)
                                        }
                                    }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                                    .stroke(AppTheme.accentChromeStroke, lineWidth: 1)
                            )
                            .shadow(color: AppTheme.deepShadowColor.opacity(0.82), radius: 28, x: 0, y: 18)
                        }
                        .buttonStyle(.plain)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Marked for review")
                        .accessibilityValue("\(appViewModel.totalMarkedCount()) cards flagged for another pass.")
                        .accessibilityHint("Double tap to open your focused review list.")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 38)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: AppTheme.rootTabBarClearance)
                }
            }
            .navigationTitle("Study")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                        Button {
                            isShowingAbout = true
                        } label: {
                            Label("About FlashCards", systemImage: "info.circle")
                        }

                        Button {
                            isShowingAppearance = true
                        } label: {
                            Label("Appearance", systemImage: "circle.lefthalf.filled")
                        }

                        Button {
                            isImportingDeck = true
                        } label: {
                            Label("Import Deck JSON", systemImage: "square.and.arrow.down")
                        }

                        Button {
                            isImportingKnowledge = true
                        } label: {
                            Label("Import Knowledge JSON", systemImage: "brain")
                        }

                        Button {
                            startSampleExport()
                        } label: {
                            Label("Export Sample JSON", systemImage: "doc.badge.plus")
                        }

                        Menu {
                            ForEach(appViewModel.decks) { deck in
                                Button(deck.title) {
                                    startDeckExport(deck)
                                }
                            }
                        } label: {
                            Label("Export Existing Deck", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Deck import and export")
                }
            }
        }
        .fileImporter(
            isPresented: $isImportingDeck,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false,
            onCompletion: handleDeckImport
        )
        .fileImporter(
            isPresented: $isImportingKnowledge,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false,
            onCompletion: handleKnowledgeImport
        )
        .fileExporter(
            isPresented: $isExportingDeck,
            document: exportDocument,
            contentType: .json,
            defaultFilename: exportFilename,
            onCompletion: handleExport
        )
        .sheet(isPresented: $isShowingAbout) {
            NavigationStack {
                AboutView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                isShowingAbout = false
                            }
                        }
                }
            }
        }
        .sheet(isPresented: $isShowingAppearance) {
            NavigationStack {
                AppearanceSettingsView()
                    .environmentObject(appearanceStore)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                isShowingAppearance = false
                            }
                        }
                }
            }
        }
        .onAppear(perform: presentStartupNoticeIfNeeded)
        .alert(item: $transferNotice) { notice in
            Alert(title: Text(notice.title), message: Text(notice.message), dismissButton: .default(Text("OK")))
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("DAILY REVIEW")
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(AppTheme.tertiaryText)

            Text("Architecture mastery with almost no friction.")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
                .lineSpacing(2)

            Text("Fast review, clean focus, and enough depth to sharpen real interview and delivery skills.")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(3)

            HStack(spacing: 10) {
                statChip(title: "Decks", value: "\(appViewModel.decks.count)")
                statChip(title: "Cards", value: "\(appViewModel.decks.reduce(0) { $0 + $1.cards.count })")
                statChip(title: "Marked", value: "\(appViewModel.totalMarkedCount())")
            }
            .padding(.top, 4)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(AppTheme.elevatedSurfaceGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.outlineGradient, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadowColor.opacity(0.72), radius: 24, x: 0, y: 14)
        .overlay(alignment: .topTrailing) {
            if AppTheme.usesAmbientGlow {
                Circle()
                    .fill(AppTheme.ambientHighlight)
                    .frame(width: 110, height: 110)
                    .blur(radius: 18)
                    .offset(x: 18, y: -24)
            }
        }
    }

    private func statChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(.caption2, design: .rounded).weight(.bold))
                .foregroundStyle(AppTheme.tertiaryText)

            Text(value)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(AppTheme.primaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.surfaceGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.outlineGradient, lineWidth: 1)
        )
    }

    private func startDeckExport(_ deck: Deck) {
        guard let deckFile = appViewModel.deckFile(for: deck.id) else { return }
        startExport(deckFile: deckFile, suggestedName: deck.title)
    }

    private func startSampleExport() {
        startExport(deckFile: appViewModel.sampleDeckFile(), suggestedName: "Sample Deck")
    }

    private func startExport(deckFile: DeckFile, suggestedName: String) {
        exportDocument = DeckFileDocument(deckFile: deckFile)
        exportFilename = sanitizedFilename(for: suggestedName)
        isExportingDeck = true
    }

    private func handleDeckImport(_ result: Result<[URL], Error>) {
        do {
            let data = try importedJSONData(from: result, emptySelectionMessage: "No JSON file was selected.")
            let deckFile = try JSONDecoder().decode(DeckFile.self, from: data)
            try appViewModel.importDeckFile(deckFile)
            transferNotice = TransferNotice(
                title: "Deck imported",
                message: "\"\(deckFile.title)\" is now available in your deck list."
            )
        } catch {
            transferNotice = TransferNotice(
                title: "Import failed",
                message: error.localizedDescription
            )
        }
    }

    private func handleKnowledgeImport(_ result: Result<[URL], Error>) {
        do {
            let data = try importedJSONData(from: result, emptySelectionMessage: "No JSON file was selected.")
            let knowledgeDeckFile = try JSONDecoder().decode(KnowledgeDeckFile.self, from: data)
            let importedKnowledge = try appViewModel.importKnowledgeDeckFile(knowledgeDeckFile)
            let deckTitle = appViewModel.deck(for: importedKnowledge.deckID)?.title ?? importedKnowledge.deckID

            transferNotice = TransferNotice(
                title: "Knowledge imported",
                message: "Grounded knowledge is now available for \"\(deckTitle)\"."
            )
        } catch {
            transferNotice = TransferNotice(
                title: "Import failed",
                message: error.localizedDescription
            )
        }
    }

    private func handleExport(_ result: Result<URL, Error>) {
        defer {
            exportDocument = nil
        }

        switch result {
        case .success:
            transferNotice = TransferNotice(
                title: "Export complete",
                message: "The deck JSON was saved successfully."
            )
        case let .failure(error):
            transferNotice = TransferNotice(
                title: "Export failed",
                message: error.localizedDescription
            )
        }
    }

    private func presentStartupNoticeIfNeeded() {
        guard transferNotice == nil,
              let notice = appViewModel.consumeStartupNotice() else {
            return
        }

        transferNotice = TransferNotice(
            title: notice.title,
            message: notice.message
        )
    }

    private func sanitizedFilename(for title: String) -> String {
        let cleaned = title
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))

        return cleaned.isEmpty ? "deck" : cleaned
    }

    private func importedJSONData(
        from result: Result<[URL], Error>,
        emptySelectionMessage: String
    ) throws -> Data {
        let url = try result.get().first ?? {
            throw DeckImportError.invalidDeck(emptySelectionMessage)
        }()

        let scoped = url.startAccessingSecurityScopedResource()
        defer {
            if scoped {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
        if let fileSize = resourceValues.fileSize, fileSize > maxImportBytes {
            throw DeckImportError.invalidDeck("JSON files must be 2 MB or smaller.")
        }

        return try Data(contentsOf: url, options: [.mappedIfSafe])
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let reviewStore = ReviewStore()
        let appViewModel = AppViewModel(reviewStore: reviewStore)
        let appearanceStore = AppearanceStore(defaults: UserDefaults(suiteName: "HomeViewPreview")!)

        return HomeView()
            .environmentObject(reviewStore)
            .environmentObject(appViewModel)
            .environmentObject(appearanceStore)
    }
}

private struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(.title3, design: .rounded).weight(.bold))
            .foregroundStyle(AppTheme.primaryText)
    }
}

private struct TransferNotice: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

private struct DeckFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let deckFile: DeckFile

    init(deckFile: DeckFile) {
        self.deckFile = deckFile
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw DeckImportError.invalidDeck("The selected file was empty.")
        }

        deckFile = try JSONDecoder().decode(DeckFile.self, from: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(deckFile)
        return FileWrapper(regularFileWithContents: data)
    }
}

private struct AboutView: View {
    private var versionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("FlashCards")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)

                    Text("Focused offline study for system design, architecture, and AWS review.")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineSpacing(3)

                    Text(versionText)
                        .font(.system(.footnote, design: .rounded).weight(.semibold))
                        .foregroundStyle(AppTheme.tertiaryText)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                        .fill(AppTheme.elevatedSurfaceGradient)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                        .stroke(AppTheme.outlineGradient, lineWidth: 1)
                )

                AboutSectionCard(
                    title: "Privacy",
                    symbolName: "hand.raised.fill",
                    rows: [
                        "No account, sync, ads, or analytics are built into this release.",
                        "Marked cards, imported decks, and study state stay on the device.",
                        "Card Assist is grounded from local deck knowledge and does not call a backend in this build."
                    ]
                )

                AboutSectionCard(
                    title: "Open Source",
                    symbolName: "chevron.left.forwardslash.chevron.right",
                    rows: [
                        "Publish the repository, license, and README together with each IPA release.",
                        "Use GitHub Issues or Discussions as the primary support channel for this project.",
                        "Attach install notes and checksums to each GitHub release so sideload users can verify what they download."
                    ]
                )

                AboutSectionCard(
                    title: "Card Assist",
                    symbolName: "sparkles",
                    rows: [
                        "Explain, Compare, Quiz, and Feedback are scoped to the current card and deck.",
                        "The deck knowledge JSON is the source of truth; the generator is only a formatter.",
                        "Foundation Models and MLX providers are placeholders and are not active in this release."
                    ]
                )

                AboutSectionCard(
                    title: "Content Notice",
                    symbolName: "book.closed.fill",
                    rows: [
                        "AWS service names are used for educational reference only.",
                        "This app is not affiliated with Amazon Web Services, Apple, or any featured vendor.",
                        "Avoid claiming official certification, partnership, or endorsement in repository copy or release notes."
                    ]
                )

                ReleaseChecklistCard()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .background(AppBackground(accentDeck: .custom))
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AppearanceSettingsView: View {
    @EnvironmentObject private var appearanceStore: AppearanceStore

    var body: some View {
        List {
            Section("Color Scheme") {
                ForEach(AppColorSchemePreference.allCases) { preference in
                    Button {
                        appearanceStore.update(colorSchemePreference: preference)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: preference.systemImage)
                                .frame(width: 24)
                                .foregroundStyle(AppTheme.primaryText)

                            Text(preference.title)
                                .foregroundStyle(AppTheme.primaryText)

                            Spacer()

                            if appearanceStore.colorSchemePreference == preference {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppTheme.accentColor(for: .custom))
                            }
                        }
                    }
                }
            }

            Section("Reading Mode") {
                ForEach(AppReadingMode.allCases) { mode in
                    Button {
                        appearanceStore.update(readingMode: mode)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: mode.systemImage)
                                .frame(width: 24)
                                .foregroundStyle(AppTheme.primaryText)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(mode.title)
                                    .foregroundStyle(AppTheme.primaryText)
                                Text(mode.detail)
                                    .font(.system(.footnote, design: .rounded))
                                    .foregroundStyle(AppTheme.secondaryText)
                                    .multilineTextAlignment(.leading)
                            }

                            Spacer()

                            if appearanceStore.readingMode == mode {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppTheme.accentColor(for: .custom))
                            }
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppBackground(accentDeck: .custom))
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AboutSectionCard: View {
    let title: String
    let symbolName: String
    let rows: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppTheme.secondarySurface)

                    Image(systemName: symbolName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryText)
                }
                .frame(width: 40, height: 40)

                Text(title)
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(AppTheme.primaryText)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(rows, id: \.self) { row in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(AppTheme.accentColor(for: .custom))
                            .frame(width: 7, height: 7)
                            .padding(.top, 6)

                        Text(row)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(AppTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppTheme.surfaceGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.outlineGradient, lineWidth: 1)
        )
    }
}

private struct ReleaseChecklistCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Before GitHub Release")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(AppTheme.primaryText)

            Text("This build is technically ready, but these release details should ship with the repository and IPA artifact.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                ChecklistRow(text: "Publish a LICENSE, README, and privacy note in the repository.")
                ChecklistRow(text: "Attach the IPA, checksum, and release notes to the GitHub release.")
                ChecklistRow(text: "Keep the release description accurate: offline, local-first, no active hosted AI provider in this build.")
                ChecklistRow(text: "Use Issues or Discussions for support and document that flow in the README.")
                ChecklistRow(text: "Avoid vendor logos or wording that implies official AWS, Apple, or Amazon affiliation.")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.secondarySurface,
                            AppTheme.tertiarySurface
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.outlineGradient, lineWidth: 1)
        )
    }
}

private struct ChecklistRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.accentColor(for: .custom))
                .padding(.top, 2)

            Text(text)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
