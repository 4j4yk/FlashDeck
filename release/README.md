# Release Assets

This directory is used for locally generated release artifacts.

Expected generated files:

- `FlashDeck-sideload.ipa`
- `FlashDeck-sideload.ipa.sha256`
- `FlashDeck-simulator.app.zip`

Generate the device IPA and checksum with:

```sh
./scripts/create-release-artifacts.sh
```

Generate the simulator artifact with:

```sh
./scripts/create-simulator-artifact.sh
```

Notes:

- the generated IPA is an unsigned device artifact for sideloading
- it is not a simulator build
- `FlashDeck-simulator.app.zip` is the simulator-friendly artifact

## Automated Release Publishing

GitHub Actions publishes these assets automatically when a tag matching `v*` is pushed.

The IPA and checksum files are ignored by Git and should be attached to GitHub Releases rather than committed.
