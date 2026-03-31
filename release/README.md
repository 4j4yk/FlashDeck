# Release Assets

This directory is used for locally generated release artifacts.

Expected generated files:

- `FlashCards-sideload.ipa`
- `FlashCards-sideload.ipa.sha256`
- `FlashCards-simulator.app.zip`

Generate them with:

```sh
./scripts/create-release-artifacts.sh
```

Notes:

- the generated IPA is an unsigned device artifact for sideloading
- it is not a simulator build
- `FlashCards-simulator.app.zip` is the simulator-friendly artifact

## Automated Release Publishing

GitHub Actions publishes these assets automatically when a tag matching `v*` is pushed.

The IPA and checksum files are ignored by Git and should be attached to GitHub Releases rather than committed.
