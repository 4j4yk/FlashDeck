# Privacy

## Summary

FlashCards is local-first in the default build.

The app does not include:

- account creation
- sign-in
- analytics SDKs
- ads
- tracking
- cloud sync
- backend API calls

## Data Stored On Device

The app stores the following on-device:

- marked-card IDs
- last-opened deck ID
- imported custom decks
- bounded Card Assist cache

These values are used only to make the local study experience work.

## Imported Decks

Imported deck JSON files are read locally and copied into app-managed local storage.

They are not uploaded anywhere by the default build.

## Card Assist

Card Assist uses deck-grounded local knowledge in this build.

It does not send prompts, answers, or imported deck content to a remote service.

## Public Releases

GitHub release downloads may be subject to GitHub's own platform logging and terms.

This privacy file covers the app behavior itself, not the hosting platform around the repository or release assets.
