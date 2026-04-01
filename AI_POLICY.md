# AI Policy

## Scope

FlashDeck includes a narrow, card-scoped assist layer.

It is not a general chatbot.

## Source Of Truth

The source of truth is:

1. the current flash card
2. the local deck knowledge files

Generation is a formatting layer over retrieved local context.

## Default Open-Source Behavior

In the default build:

- assist is offline-first
- no backend inference is used
- template generation is always available
- grounded deck snippets are shown as references when available

## Retrieval Rules

- bundled knowledge can ground built-in decks directly
- imported runtime knowledge applies only to the exact matching `deck_id`
- if no explicit knowledge exists, the app can synthesize fallback knowledge from the current deck cards

This keeps the assist layer predictable and avoids hidden cross-deck overrides.

## Future Providers

The architecture allows future local providers such as:

- Apple Foundation Models on supported devices
- MLX-based local models

Those providers are placeholders in the current repository and are not active by default.

## Data Handling

- assist requests are handled locally in the default build
- imported deck and knowledge files stay local
- the default build does not train on user data
- the default build does not upload deck, study, or assist data to a service

## Product Boundaries

- generated wording is advisory, not authoritative
- deck knowledge should remain the final study reference
- no medical, legal, or financial guarantees are implied
