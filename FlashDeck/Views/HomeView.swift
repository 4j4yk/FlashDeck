import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var reviewStore: ReviewStore
    @EnvironmentObject private var appearanceStore: AppearanceStore

    private let maxImportBytes = 2_000_000
    private let walkthroughStorageKey = "flashdeck.didShowWalkthrough.v1"
    private let appResetNonceKey = "flashdeck.appResetNonce"

    @State private var isImportingDeck = false
    @State private var isImportingKnowledge = false
    @State private var isExportingDeck = false
    @State private var isExportingKnowledge = false
    @State private var isShowingAbout = false
    @State private var isShowingAppearance = false
    @State private var isShowingResetAppAlert = false
    @State private var exportDocument: DeckFileDocument?
    @State private var knowledgeExportDocument: KnowledgeDeckFileDocument?
    @State private var exportFilename = "deck"
    @State private var knowledgeExportFilename = "deck-knowledge"
    @State private var alertNotice: TransferNotice?
    @State private var bannerNotice: TransferNotice?
    @State private var bannerDismissTask: Task<Void, Never>?

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
                                    .fill(AppTheme.gradient(for: .custom))
                                    .overlay(alignment: .topTrailing) {
                                        if AppTheme.usesAmbientGlow {
                                            Circle()
                                                .stroke(.white.opacity(0.12), lineWidth: 1.2)
                                                .frame(width: 132, height: 132)
                                                .overlay {
                                                    Circle()
                                                        .fill(AppTheme.ambientHighlight)
                                                        .blur(radius: 22)
                                                }
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
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        isShowingAppearance = true
                    } label: {
                        Image(systemName: "paintbrush")
                    }
                    .accessibilityLabel("Appearance")

                    Menu {
                        Section("About") {
                            Button {
                                isShowingAbout = true
                            } label: {
                                Label("About FlashDeck", systemImage: "info.circle")
                            }
                        }

                        Section("Deck Files") {
                            Button {
                                isImportingDeck = true
                            } label: {
                                Label("Import Deck JSON", systemImage: "square.and.arrow.down")
                            }

                            Button {
                                startSampleExport()
                            } label: {
                                Label("Export Sample Deck JSON", systemImage: "doc.badge.plus")
                            }

                            Menu {
                                ForEach(appViewModel.decks) { deck in
                                    Button(deck.title) {
                                        startDeckExport(deck)
                                    }
                                }
                            } label: {
                                Label("Export Installed Deck", systemImage: "square.and.arrow.up")
                            }
                        }

                        Section("Assist Knowledge") {
                            Button {
                                isImportingKnowledge = true
                            } label: {
                                Label("Import Knowledge JSON", systemImage: "brain")
                            }

                            Menu {
                                ForEach(appViewModel.decks) { deck in
                                    Button(deck.title) {
                                        startKnowledgeExport(deck)
                                    }
                                }
                            } label: {
                                Label("Export Deck Knowledge", systemImage: "brain.head.profile")
                            }
                        }

                        Section("Reset") {
                            Button(role: .destructive) {
                                isShowingResetAppAlert = true
                            } label: {
                                Label("Reset App to Default", systemImage: "trash.fill")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("More options")
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
        .fileExporter(
            isPresented: $isExportingKnowledge,
            document: knowledgeExportDocument,
            contentType: .json,
            defaultFilename: knowledgeExportFilename,
            onCompletion: handleKnowledgeExport
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
        .onDisappear {
            bannerDismissTask?.cancel()
            bannerDismissTask = nil
        }
        .confirmationDialog("Reset All Local Data?", isPresented: $isShowingResetAppAlert, titleVisibility: .visible) {
            Button("Erase and Reset", role: .destructive) {
                Task { @MainActor in
                    await factoryRestore()
                }
            }
        } message: {
            Text("This returns the app to its first-install state. Imported decks, imported knowledge, review marks, appearance choices, the local assist cache, the last opened deck, and the walkthrough state will all be cleared. Built-in decks stay available.")
        }
        .alert(item: $alertNotice) { notice in
            Alert(title: Text(notice.title), message: Text(notice.message), dismissButton: .default(Text("OK")))
        }
        .overlay(alignment: .bottom) {
            if let bannerNotice {
                NoticeBanner(notice: bannerNotice)
                    .padding(.horizontal, 20)
                    .padding(.bottom, AppTheme.rootTabBarClearance + 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onTapGesture {
                        dismissBanner()
                    }
            }
        }
        .animation(.easeOut(duration: 0.22), value: bannerNotice?.id)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("FLASHDECK")
                .font(.system(.caption, design: .monospaced).weight(.bold))
                .tracking(1.6)
                .foregroundStyle(AppTheme.tertiaryText)

            Text("Fast recall with grounded technical depth.")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .foregroundStyle(AppTheme.primaryText)
                .lineSpacing(2)

            Text("FlashDeck keeps the interaction honest: quick card review first, then deeper grounded context when you need it.")
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

    private func startKnowledgeExport(_ deck: Deck) {
        guard let knowledgeDeckFile = appViewModel.knowledgeDeckFile(for: deck.id) else {
            presentBanner(
                title: "Nothing to export",
                message: "No grounded knowledge is available for \"\(deck.title)\" yet."
            )
            return
        }

        knowledgeExportDocument = KnowledgeDeckFileDocument(deckFile: knowledgeDeckFile)
        knowledgeExportFilename = "\(sanitizedFilename(for: deck.title))-knowledge"
        isExportingKnowledge = true
    }

    private func startExport(deckFile: DeckFile, suggestedName: String) {
        exportDocument = DeckFileDocument(deckFile: deckFile)
        exportFilename = sanitizedFilename(for: suggestedName)
        isExportingDeck = true
    }

    private func handleDeckImport(_ result: Result<[URL], Error>) {
        do {
            let data = try importedJSONData(from: result, emptySelectionMessage: "No JSON file was selected.")
            let deckFile = try decodeDeckFile(from: data)
            try appViewModel.importDeckFile(deckFile)
            presentBanner(
                title: "Deck imported",
                message: "\"\(deckFile.title)\" is now available in your deck list."
            )
        } catch {
            alertNotice = TransferNotice(
                title: "Import failed",
                message: error.localizedDescription
            )
        }
    }

    private func handleKnowledgeImport(_ result: Result<[URL], Error>) {
        do {
            let data = try importedJSONData(from: result, emptySelectionMessage: "No JSON file was selected.")
            let knowledgeDeckFile = try decodeKnowledgeDeckFile(from: data)
            let importedKnowledge = try appViewModel.importKnowledgeDeckFile(knowledgeDeckFile)
            let deckTitle = appViewModel.deck(for: importedKnowledge.deckID)?.title
            let message: String
            if let deckTitle {
                message = "Grounded assist knowledge for \"\(deckTitle)\" is ready. This updates Explain, Compare, Quiz Me, and Feedback, not the deck list."
            } else {
                message = "Knowledge for deck id \"\(importedKnowledge.deckID)\" was stored. It will be used when a deck with that id is available."
            }
            presentBanner(
                title: "Knowledge imported",
                message: message
            )
        } catch {
            alertNotice = TransferNotice(
                title: "Import failed",
                message: error.localizedDescription
            )
        }
    }

    private func handleKnowledgeExport(_ result: Result<URL, Error>) {
        defer {
            knowledgeExportDocument = nil
        }

        switch result {
        case .success:
            presentBanner(
                title: "Knowledge exported",
                message: "The grounded knowledge JSON was saved successfully."
            )
        case let .failure(error):
            alertNotice = TransferNotice(
                title: "Export failed",
                message: error.localizedDescription
            )
        }
    }

    @MainActor
    private func factoryRestore() async {
        await appViewModel.resetLocalData()
        reviewStore.reset()
        appearanceStore.reset()
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: walkthroughStorageKey)
        defaults.set(defaults.integer(forKey: appResetNonceKey) + 1, forKey: appResetNonceKey)
        alertNotice = nil
        dismissBanner()
    }

    private func handleExport(_ result: Result<URL, Error>) {
        defer {
            exportDocument = nil
        }

        switch result {
        case .success:
            presentBanner(
                title: "Export complete",
                message: "The deck JSON was saved successfully."
            )
        case let .failure(error):
            alertNotice = TransferNotice(
                title: "Export failed",
                message: error.localizedDescription
            )
        }
    }

    private func presentStartupNoticeIfNeeded() {
        guard alertNotice == nil,
              let notice = appViewModel.consumeStartupNotice() else {
            return
        }

        alertNotice = TransferNotice(
            title: notice.title,
            message: notice.message
        )
    }

    private func presentBanner(title: String, message: String) {
        bannerDismissTask?.cancel()
        bannerNotice = TransferNotice(title: title, message: message)

        bannerDismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard Task.isCancelled == false else { return }
            withAnimation(.easeOut(duration: 0.22)) {
                bannerNotice = nil
            }
        }
    }

    private func dismissBanner() {
        bannerDismissTask?.cancel()
        bannerDismissTask = nil
        withAnimation(.easeOut(duration: 0.18)) {
            bannerNotice = nil
        }
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

        guard let stream = InputStream(url: url) else {
            throw DeckImportError.invalidDeck("The selected file could not be opened.")
        }

        stream.open()
        defer {
            stream.close()
        }

        var data = Data()
        let chunkSize = 64 * 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: chunkSize)
        defer {
            buffer.deallocate()
        }

        while stream.hasBytesAvailable {
            let bytesRead = stream.read(buffer, maxLength: chunkSize)

            if bytesRead < 0 {
                throw stream.streamError ?? DeckImportError.invalidDeck("The selected file could not be read.")
            }

            if bytesRead == 0 {
                break
            }

            data.append(buffer, count: bytesRead)

            if data.count > maxImportBytes {
                throw DeckImportError.invalidDeck("JSON files must be 2 MB or smaller.")
            }
        }

        return data
    }

    private func decodeDeckFile(from data: Data) throws -> DeckFile {
        do {
            return try JSONDecoder().decode(DeckFile.self, from: data)
        } catch let error as DecodingError {
            throw DeckImportError.invalidDeck(
                "This JSON does not match the deck format. Use \"Import Knowledge JSON\" only for grounded assist files.\n\n\(friendlyDecodingMessage(for: error))"
            )
        } catch {
            throw error
        }
    }

    private func decodeKnowledgeDeckFile(from data: Data) throws -> KnowledgeDeckFile {
        do {
            return try JSONDecoder().decode(KnowledgeDeckFile.self, from: data)
        } catch let error as DecodingError {
            throw KnowledgeImportError.invalidKnowledge(
                "This JSON does not match the knowledge format. Use \"Import Deck JSON\" for study decks.\n\n\(friendlyDecodingMessage(for: error))"
            )
        } catch {
            throw error
        }
    }

    private func friendlyDecodingMessage(for error: DecodingError) -> String {
        switch error {
        case let .keyNotFound(key, _):
            return "Missing expected field: \(key.stringValue)."
        case let .typeMismatch(_, context):
            return "Unexpected value near \(codingPathDescription(for: context.codingPath))."
        case let .valueNotFound(_, context):
            return "Missing value near \(codingPathDescription(for: context.codingPath))."
        case let .dataCorrupted(context):
            return context.debugDescription
        @unknown default:
            return "The JSON structure could not be read."
        }
    }

    private func codingPathDescription(for codingPath: [CodingKey]) -> String {
        let path = codingPath.map(\.stringValue).joined(separator: ".")
        return path.isEmpty ? "the top level" : path
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

private struct NoticeBanner: View {
    let notice: TransferNotice

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.accentColor(for: .custom))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(notice.title)
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(AppTheme.primaryText)

                Text(notice.message)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppTheme.elevatedSurfaceGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppTheme.outlineGradient, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadowColor.opacity(0.32), radius: 18, x: 0, y: 10)
        .accessibilityElement(children: .combine)
    }
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

private struct KnowledgeDeckFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let deckFile: KnowledgeDeckFile

    init(deckFile: KnowledgeDeckFile) {
        self.deckFile = deckFile
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw KnowledgeImportError.invalidKnowledge("The selected file was empty.")
        }

        deckFile = try JSONDecoder().decode(KnowledgeDeckFile.self, from: data)
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
                    Text("FlashDeck")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundStyle(AppTheme.primaryText)

                    Text("Offline flash cards for system design, solution architecture, and AWS study. FlashDeck emphasizes quick recall first, with grounded deck knowledge ready when you want more context.")
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
                    title: "Why FlashDeck",
                    symbolName: "point.3.connected.trianglepath.dotted",
                    rows: [
                        "The name reflects the core interaction directly: fast card-based recall in focused study sessions.",
                        "Decks stay compact and repeatable, while grounded knowledge adds depth without turning the app into chat.",
                        "The product stays honest to what it is: a flash-card app first, with technical understanding layered on top."
                    ]
                )

                AboutSectionCard(
                    title: "How It Works",
                    symbolName: "square.stack.3d.up.fill",
                    rows: [
                        "Built for short, repeatable review sessions instead of a generic chat experience.",
                        "Decks load instantly from local bundled data, and you can extend them with your own JSON files.",
                        "Core study flows stay useful even with no model available."
                    ]
                )

                AboutSectionCard(
                    title: "Privacy & Storage",
                    symbolName: "hand.raised.fill",
                    rows: [
                        "No account, sync, ads, analytics, or background service is required in this build.",
                        "Marked cards, imported decks, imported knowledge, and study state stay on the device.",
                        "Import and export use local Files access only."
                    ]
                )

                AboutSectionCard(
                    title: "Card Assist",
                    symbolName: "sparkles",
                    rows: [
                        "Explain, Compare, Quiz, and Feedback are scoped to the current card and deck.",
                        "Deck knowledge is the source of truth; the generator only formats grounded output.",
                        "If no local model provider is available, the app falls back to deterministic grounded responses."
                    ]
                )

                AboutSectionCard(
                    title: "Open Source",
                    symbolName: "chevron.left.forwardslash.chevron.right",
                    rows: [
                        "The repository is the primary place for releases, documentation, and issue tracking.",
                        "Each public IPA release should ship with checksums, release notes, and sample JSON formats.",
                        "Custom decks and knowledge files are intentionally plain JSON so they can be inspected and versioned."
                    ]
                )

                AboutSectionCard(
                    title: "Content & Sources",
                    symbolName: "book.closed.fill",
                    rows: [
                        "AWS service names are used for educational reference only.",
                        "This app is not affiliated with Amazon Web Services, Apple, or any featured vendor.",
                        "Use official vendor documentation as the final authority for production decisions."
                    ]
                )

                BuildSummaryCard()
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

private struct BuildSummaryCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Good to Know")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(AppTheme.primaryText)

            Text("A few practical notes for using this release well.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                ChecklistRow(text: "Core study, search, marking, and review work fully offline.")
                ChecklistRow(text: "Import Deck JSON to add a custom deck or update one you already use.")
                ChecklistRow(text: "Import Knowledge JSON to improve grounded assist for a matching deck.")
                ChecklistRow(text: "Knowledge files do not create a new deck by themselves.")
                ChecklistRow(text: "Plain JSON keeps custom decks and knowledge easy to inspect, edit, and version.")
                ChecklistRow(text: "If deck ids match, imported knowledge and saved review state stay aligned.")
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
