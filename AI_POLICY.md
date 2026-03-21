# AI Policy

## Scope

FlashCards includes a narrow, card-scoped assist layer.

It is not a general chatbot.

## Source Of Truth

The source of truth is:

1. the current flash card
2. the local deck knowledge files

Generation is a presentation layer over retrieved local context.

## Default Behavior

In the default open-source build:

- assist is offline-first
- no backend inference is used
- template generation is always available
- grounded deck snippets are shown as references

## Future Providers

The architecture allows future local providers such as:

- Apple Foundation Models on supported devices
- MLX-based local models

Those providers are placeholders in the current repository and are not active by default.

## Data Handling

- user prompts for assist are handled locally
- imported deck knowledge stays local
- the default build does not train on user data
- the default build does not upload deck or study data to a service

## Product Boundaries

- no medical, legal, or financial guarantees
- no claim that generated wording is authoritative
- use the retrieved deck knowledge as the final study reference
