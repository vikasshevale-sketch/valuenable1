# Valuenable Secure Workspace iOS

Source-only Xcode project for a controlled Valuenable Google Workspace web container.

## Important repository rule

There is **one authoritative source tree**: `SecureWorkspace/`.
Do not add duplicate `WebContainer/`, `Security/`, or `DocumentViewer/` folders at repository root.
Do not commit `.ipa`, `Payload/`, Xcode archives, DerivedData, or `*.metadata.json` files.

## Authentication fix

The previous project contained duplicate source files and the Xcode project referenced the root duplicate implementation. That could build an older `DomainGuard` and produce the message:

> Navigation outside of the authorized 'valuenable.in' workspace is blocked for security.

The final project references only `SecureWorkspace/WebContainer/*` and does not inject `X-GoogApps-Allowed-Domains` or other Google authentication headers.

The WebView uses the persistent `WKWebsiteDataStore.default()` so normal website cookies/session state can persist. The domain guard explicitly permits the Google Workspace origins commonly required by Gmail authentication and its web resources; it does not inject Google authentication headers.

### Google limitation

Google may reject OAuth/sign-in inside an embedded `WKWebView` with `disallowed_useragent` or a similar policy error. A domain allow-list cannot fix that. If that happens, production authentication must use a Google-supported native OAuth/OIDC flow (for example Google Sign-In or `ASWebAuthenticationSession`) and a configured iOS OAuth client ID. This source does not invent credentials or client IDs.

## Build

1. Open `SecureWorkspace.xcodeproj` in Xcode.
2. Select the `SecureWorkspace` target.
3. Select your Apple Developer Team under **Signing & Capabilities**.
4. Confirm Bundle Identifier: `in.valuenable.secureworkspace`.
5. Clean Build Folder.
6. Delete the old app from the iPhone.
7. Build and run again.

For CI/unsigned archive generation, use the included GitHub Actions workflow.

## Repository contents

- `.github/workflows/main.yml` — CI build workflow
- `SecureWorkspace.xcodeproj/` — Xcode project
- `SecureWorkspace/` — all application source
- `ExportOptions.plist` — export configuration
- `manifest.plist` — optional OTA distribution manifest
- `build_and_export.sh` — local archive/export script
- `.gitignore` — prevents build artifacts from being committed

## Security notes

The app includes the existing biometric lock, jailbreak checks, screen-capture overlay, secure web container, download handling, and copy/context-menu restrictions.

These controls are defense-in-depth. iOS screenshots, screen recording, Google authentication policy, and managed-device controls have platform-specific limitations and must be validated on a real device before production deployment.
