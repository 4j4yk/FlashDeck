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
  -destination 'generic/platform=iOS Simulator' \
  build
```

## Release Build

```sh
./scripts/create-release-artifacts.sh
```

## Contribution Guidelines

- keep the architecture small
- avoid unnecessary dependencies
- prefer file-backed local storage for mutable payloads that may grow
- keep AI assist narrow and card-scoped
- keep deck knowledge grounded and concise
- preserve offline-first behavior in the default build

## Pull Request Checklist

- build succeeds locally
- new user-facing behavior is documented
- privacy and AI claims stay accurate
- no placeholder marketing copy
- generated artifacts are not committed
