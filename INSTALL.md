# Install And Sideload

## Download From GitHub Releases

1. Open the latest GitHub Release for this repository.
2. Download:
   - `FlashCards-sideload.ipa`
   - `FlashCards-sideload.ipa.sha256`
3. Verify the checksum locally:

```sh
shasum -a 256 FlashCards-sideload.ipa
```

Compare the output to the `.sha256` file from the release.

## Install With A Sideload Tool

This IPA is unsigned by design. A sideload tool signs it during install with your Apple account.

Supported tools:

- AltStore Classic
- SideStore
- Sideloadly

General steps:

1. Install one of the sideload tools on your Mac or PC.
2. Add your Apple ID to that tool as required by the tool's normal flow.
3. Choose `FlashCards-sideload.ipa` as the app to install.
4. Let the tool sign and install the IPA.
5. On the device, trust the developer profile if prompted.
6. Enable Developer Mode if the sideload tool requires it.

Official docs:

- AltStore Classic: <https://faq.altstore.io/altstore-classic/how-to-install-altstore-macos>
- SideStore: <https://docs.sidestore.io/docs/installation/install>
- Sideloadly: <https://sideloadly.io/>

## Troubleshooting

- If install fails, make sure the IPA checksum matches the release note.
- If the app will not open, trust the developer profile in `Settings > General > VPN & Device Management`.
- If the sideload tool warns about app limits, refresh or remove old sideloaded apps tied to the same Apple ID.
- If the install succeeds but the app crashes immediately, use the matching release notes and confirm you downloaded the latest asset pair.

## Build It Yourself

To generate the IPA locally:

```sh
./scripts/create-release-artifacts.sh
```
