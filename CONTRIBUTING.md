# Contributing

## Prerequisites

- Xcode 17 or newer
- iOS 17 SDK or newer
- macOS with simulator support for local testing

## Local Development

Build in Xcode or from the command line:

```sh
xcodebuild \
  -project FlashCards.xcodeproj \
  -scheme FlashCards \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build
```

Run tests:

```sh
xcodebuild \
  -project FlashCards.xcodeproj \
  -scheme FlashCards \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  test
```

## Release Build

```sh
./scripts/create-release-artifacts.sh
```

## Contribution Guidelines

- keep the architecture small
- avoid unnecessary dependencies
- prefer local-first behavior in the default build
- keep AI assist narrow and card-scoped
- keep deck knowledge grounded and concise
- use file-backed storage for mutable payloads that may grow
- keep docs accurate when behavior changes

## Deck And Knowledge Content Rules

- prefer practical, architect-level explanations over trivia
- keep answers compact enough for flashcard study
- maintain stable `deck_id` and `card_id` values when updating an existing pack
- maintain stable knowledge document IDs where possible
- use JSON formats that stay easy to review in pull requests
- avoid copying large source text verbatim from third-party material

## Pull Request Checklist

- build succeeds locally
- tests pass locally
- new user-facing behavior is documented
- privacy and AI claims stay accurate
- release/install docs still match the actual artifacts
- generated artifacts are not committed
