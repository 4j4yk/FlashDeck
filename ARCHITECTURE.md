# Architecture

## Goals

- keep the app small
- keep state local
- make the AI layer replaceable
- avoid overengineering

## Runtime Structure

### App Shell

`StudyCardsApp.swift` creates the top-level stores and injects them into SwiftUI.

### Data Model

- `Deck` is the deck container used by the UI
- `FlashCard` is the core study unit
- `DeckFile` is the import/export schema
- `KnowledgeDocument` is the local grounded knowledge schema

### Persistence

- `ReviewStore` persists marked-card IDs
- `CustomDeckStore` persists imported decks to `Application Support`
- `CardAssistCache` persists a bounded assist cache to `Application Support`

### Knowledge And Assist

- `KnowledgeStore` loads bundled knowledge JSON and synthesizes fallback knowledge for imported decks
- `KnowledgeRetriever` uses exact title, aliases, tags, keywords, and related concept lookup
- `GroundedCardAssistService` coordinates retrieval and generation
- `TemplateGenerationProvider` keeps the app useful without a model
- `FoundationModelsGenerationProvider` and `MLXGenerationProvider` are placeholders for future local model integrations

### View Model

`AppViewModel` keeps deck loading, import/export helpers, search filtering, and marked counts in one place.

### UI

SwiftUI views stay thin:

- `HomeView` for deck discovery and project/about info
- `DeckBrowserView` for list and multi-select review marking
- `StudyView` for card study and assist
- `MarkedCardsView` for focused review

## Design Notes

- The app treats bundled deck knowledge as the source of truth.
- AI assist is a formatting layer over retrieved local context.
- Search and review state are intentionally simple and deterministic.
- Mutable user data uses file-backed storage instead of `UserDefaults` blobs where size can grow over time.

## Extension Points

- add more deck knowledge files
- add imported knowledge bundles
- swap in an on-device generation provider
- replace the review store with a spaced-repetition scheduler later
