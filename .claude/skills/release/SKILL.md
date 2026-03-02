---
name: release
description: Build and release the Flutter iOS app to App Store or TestFlight via Fastlane.
disable-model-invocation: true
allowed-tools: Bash(fastlane *), Bash(flutter *), Bash(cd *), Bash(git *)
argument-hint: [beta|release]
---

# Flutter iOS Release

Execute a release build and upload for this Flutter iOS app.

## Arguments

- `$ARGUMENTS` should be one of: `beta` (TestFlight) or `release` (App Store). Default to `beta` if not specified.

## Pre-flight Checks

1. Run `flutter analyze` in the project root to ensure no static errors.
2. Run `git status` to verify the working tree is clean. If there are uncommitted changes, warn the user and ask whether to proceed.
3. Verify the API key file exists at `ios/fastlane/AuthKey_7V674759N8.p8`.

## Build & Upload

Run the Fastlane lane from the `ios/` directory:

```bash
cd ios && fastlane $ARGUMENTS
```

This will:
- Auto-increment the build number based on the latest TestFlight build
- Build the Flutter app with `flutter build ios --release --no-codesign`
- Sign and archive with Xcode (`Runner.xcworkspace`, scheme `Runner`)
- Upload to TestFlight (`beta`) or App Store Connect (`release`)

## Post-release

1. Report the result to the user (success or failure with error details).
2. If successful, show the new build number.
3. Ask the user if they want to commit the build number change and tag it in git.

## Configuration Reference

| Key | Value |
|-----|-------|
| Bundle ID | `me.elanchou.vault` |
| Team ID | `HSJP264LHP` |
| API Key ID | `7V674759N8` |
| Issuer ID | `69a6de88-9503-47e3-e053-5b8c7c11a4d1` |
| App Name | Sault. |
