# Release Assets

This directory is used for locally generated release artifacts.

Expected generated files:

- `FlashCards-sideload.ipa`
- `FlashCards-sideload.ipa.sha256`

Generate them with:

```sh
./scripts/create-release-artifacts.sh
```

The IPA and checksum files are ignored by Git and should be attached to GitHub Releases rather than committed.
