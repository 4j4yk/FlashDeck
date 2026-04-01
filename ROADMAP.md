# Roadmap

## Product Direction

FlashDeck should stay small, local-first, and content-driven.

The roadmap is intentionally focused on better decks, better grounding, and better install flows rather than on turning the app into a generic study platform.

## Near-Term Priorities

### 1. More Installable Decks

Add more high-quality decks in focused domains such as:

- networking fundamentals
- Kubernetes and platform engineering
- databases and data modeling
- security architecture
- incident response and observability
- cloud cost and resiliency design

The priority is depth and practical use cases, not sheer card count.

### 2. Public Deck Catalog

Move beyond raw file import as the primary discovery path.

Preferred model:

- a published `index.json`
- deck metadata, version, checksum, and download URLs
- install/update UI inside the app
- optional companion knowledge pack per deck

Good hosting options:

- GitHub Releases
- GitHub Pages
- raw JSON served from a stable repository path

### 3. Community Deck Packs

Support community-created content without adding executable plugins.

Recommended ecosystem:

- deck packs as plain JSON
- knowledge packs as plain JSON
- stable `deck_id` and `card_id` values
- semantic versioning for released deck packs
- checksums for install verification

Community source ideas:

- official deck packs in this repository
- topic-specific repositories that publish deck releases
- curated lists of community packs maintained in a catalog index
- verified deck collections reviewed through pull requests

### 4. Better Grounded Assist

Continue improving Card Assist without turning it into a chatbot.

Likely next steps:

- richer bundled knowledge for every shipped deck
- stronger compare relationships between concepts
- better quiz and feedback rubrics
- optional local summarization providers layered on top of retrieval

## Mid-Term Priorities

### Runtime Deck Catalog Updates

Allow the app to:

- fetch a public deck catalog
- install packs selectively
- update installed packs when a newer version is available
- show whether a pack also ships grounded knowledge

### Better Import UX

Keep file import for advanced users, but make it secondary to installable packs and curated sources.

### Focused Study Analytics

Add lightweight local-only insight such as:

- cards reviewed today
- marked cards cleared
- deck progress
- streaks

No backend or account requirement.

## Long-Term Ideas

- optional local Foundation Models provider on supported Apple devices
- optional MLX-based provider for advanced offline assist
- semantic retrieval layered on top of the current deterministic retriever
- richer authoring/export tools for community maintainers

## Non-Goals

The project should avoid:

- arbitrary code plugins
- scraping adapters
- remote dependency for core study flow
- generic assistant chat UX
- cloud-synced personal study profiles in the default build

## Why The Deck Ecosystem Matters

The most valuable evolution for this app is not “more app features.” It is a better content pipeline:

- high-quality decks
- grounded knowledge packs
- simple install/update flows
- open, reviewable formats that contributors can understand

That keeps the app small while still making it more useful over time.
