# Install And Sideload

## Download Release Assets

From the published GitHub release, download:

- `FlashCards-sideload.ipa`
- `FlashCards-sideload.ipa.sha256`

Verify the checksum locally:

```sh
shasum -a 256 FlashCards-sideload.ipa
```

Compare the output to the `.sha256` file from the same release.

## Install With A Sideload Tool

The IPA is unsigned by design. A sideload tool signs it during install with your Apple account.

Supported tools:

- AltStore Classic
- SideStore
- Sideloadly

General steps:

1. Install one of the supported sideload tools on your Mac or PC.
2. Add your Apple ID to that tool as required by the tool's normal flow.
3. Choose `FlashCards-sideload.ipa` as the app to install.
4. Let the tool sign and install the IPA.
5. On the device, trust the developer profile if prompted.
6. Enable Developer Mode if the sideload tool requires it.

Official docs:

- AltStore Classic: <https://faq.altstore.io/altstore-classic/how-to-install-altstore-macos>
- SideStore: <https://docs.sidestore.io/docs/installation/install>
- Sideloadly: <https://sideloadly.io/>

## Important Artifact Note

- the IPA is for iPhone or iPad device sideloading
- the IPA is not a simulator artifact
- simulator testing uses the built `.app` from Xcode or `xcodebuild`
- GitHub Releases may also include `FlashCards-simulator.app.zip` for contributor testing on Simulator

## Build It Yourself

Generate a local unsigned release IPA:

```sh
./scripts/create-release-artifacts.sh
```

This writes:

- `release/FlashCards-sideload.ipa`
- `release/FlashCards-sideload.ipa.sha256`

## Troubleshooting

- If install fails, verify the checksum before retrying.
- If the app will not open, trust the developer profile in `Settings > General > VPN & Device Management`.
- If the sideload tool warns about app limits, refresh or remove old sideloaded apps tied to the same Apple ID.
- If you need to test in the simulator, build the app locally instead of trying to install the IPA.
