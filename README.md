# FlashCards

FlashCards is a small native iOS study app for technical interview prep and architecture review.

It is built with Swift and SwiftUI, ships with local deck content, and keeps review state on-device.

## Highlights

- Native iOS app with fast startup and no backend
- Preloaded decks for System Design, Solution Architecture, and AWS Services
- Offline-first study flow with deck-grounded card assist
- Import and export for custom decks in JSON
- Sideload-friendly release flow for GitHub releases

## Architecture

The app uses a deliberately small architecture:

- `Models`
  - `Deck`, `FlashCard`, `DeckFile`, `CardAssist` request/response types
- `Data`
  - bundled seed decks
- `Knowledge`
  - local deck knowledge documents and a lightweight retriever
- `Services`
  - grounded assist service plus generation provider boundary
- `Store`
  - review state persistence
- `ViewModels`
  - one app-level view model for deck loading and derived state
- `Views`
  - SwiftUI screens and small reusable components

Design patterns used:

- value types for app data
- protocol boundary for AI assist providers
- local-source-of-truth deck knowledge
- file-backed persistence for mutable data
- thin views with minimal business logic

See `ARCHITECTURE.md` for a slightly deeper walkthrough.

## Privacy And AI

- No account, auth, sync, analytics, ads, or backend in the default build
- Review state, imported decks, and assist cache stay on-device
- Card Assist is narrow and deck-scoped, not chat
- Local deck knowledge is the source of truth for assist output

See `PRIVACY.md` and `AI_POLICY.md`.

## Build And Run

Open `FlashCards.xcodeproj` in Xcode and run the `FlashCards` scheme on an iPhone simulator or device.

Command line simulator build:

```sh
xcodebuild \
  -project FlashCards.xcodeproj \
  -scheme FlashCards \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  build
```

Command line test run:

```sh
xcodebuild \
  -project FlashCards.xcodeproj \
  -scheme FlashCards \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  test
```

## Create A Release IPA

Use the included release script:

```sh
./scripts/create-release-artifacts.sh
```

It builds an unsigned device IPA and writes:

- `release/FlashCards-sideload.ipa`
- `release/FlashCards-sideload.ipa.sha256`

The IPA is unsigned on purpose so tools such as AltStore Classic, SideStore, or Sideloadly can sign it during sideload install.

## Download And Sideload

See `INSTALL.md`.

## Repository Policy Files

- `LICENSE`
- `SECURITY.md`
- `SUPPORT.md`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `PRIVACY.md`
- `AI_POLICY.md`
- `CRAWLING.md`
- `CHANGELOG.md`
- `CITATION.cff`

## Support

Use GitHub Issues for reproducible bugs and GitHub Discussions for questions or product ideas.

See `SUPPORT.md`.

## License

This repository is released under the MIT License. See `LICENSE`.
