# Developer Instructions

This document covers everything needed to develop, test, and publish the `plugin_mappintelligence` Flutter plugin.

---

## Table of Contents

1. [Project Setup](#1-project-setup)
2. [Running Tests](#2-running-tests)
3. [Running the Example App](#3-running-the-example-app)
4. [Making a Release](#4-making-a-release)
5. [Publishing to pub.dev — One-Time Setup](#5-publishing-to-pubdev--one-time-setup)
6. [Publishing a New Version](#6-publishing-a-new-version)
7. [Verifying the Publish Workflow Locally](#7-verifying-the-publish-workflow-locally)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Project Setup

**Requirements:**
- Flutter SDK (stable channel) — [install guide](https://docs.flutter.dev/get-started/install)
- Dart SDK (included with Flutter)
- Android Studio or Xcode for platform-specific development

**Clone and install:**
```bash
git clone https://github.com/mapp-digital/Mapp-Intelligence-Flutter-Tracking.git
cd Mapp-Intelligence-Flutter-Tracking
flutter pub get
cd example && flutter pub get && cd ..
```

---

## 2. Running Tests

**All unit tests:**
```bash
flutter test
```

**Specific test file:**
```bash
flutter test test/web_tracking_controller_test.dart
flutter test test/plugin_mappintelligence_test.dart
```

**With verbose output:**
```bash
flutter test --reporter expanded
```

**What the tests cover:**

| File | Coverage |
|---|---|
| `test/plugin_mappintelligence_test.dart` | All public API methods, channel argument verification, version sync between `pubspec.yaml` and source code |
| `test/web_tracking_controller_test.dart` | NavigationDelegate forwarding, EverID injection ordering, onLoad success/failure behavior, JavaScript channel dispatch |

**Version sync test** — verifies `pubspec.yaml` version matches the hardcoded string in `lib/plugin_mappintelligence.dart`:
```bash
flutter test --name "version sync"
```

---

## 3. Running the Example App

```bash
cd example
flutter run
```

The example app demonstrates all tracking features:
- Page tracking, action tracking, campaign tracking
- Ecommerce and media tracking
- WebView session linking
- Exception tracking
- Form tracking

---

## 4. Making a Release

Follow these steps in order before publishing:

### Step 1 — Update version in `pubspec.yaml`
```yaml
version: <VERSION>
```

### Step 2 — Update version in `lib/plugin_mappintelligence.dart`
Find `_updateCustomParams()` and update the hardcoded string to match:
```dart
final flutterPluginVersion = "<VERSION>";
```

### Step 3 — Update `CHANGELOG.md`
Add a new section at the top:
```markdown
## <VERSION>
- Description of changes
```

### Step 4 — Run the version sync test
```bash
flutter test --name "version sync"
```

### Step 5 — Run all tests
```bash
flutter test
```

### Step 6 — Dry run
```bash
dart pub publish --dry-run
```

### Step 7 — Commit and push to `main`
```bash
git add -A
git commit -m "chore: release <VERSION>"
git push origin main
```

The `validate.yml` GitHub Actions workflow runs automatically on every push to `main` — it verifies formatting, analysis, tests, and a dry run. Wait for it to pass before proceeding to publish.

---

## 5. Publishing to pub.dev — One-Time Setup

This only needs to be done once. It authorizes GitHub Actions to publish using OIDC — no credentials or tokens required.

1. Go to `https://pub.dev/packages/plugin_mappintelligence/admin`
2. Sign in with the account that owns the package
3. Scroll to **Automated publishing**
4. Click **Enable publishing from GitHub Actions**
5. Fill in:
   - **Repository:** `mapp-digital/Mapp-Intelligence-Flutter-Tracking`
   - **Tag pattern:** `v{{version}}`
6. Click **Save**

---

## 6. Publishing a New Version

After completing [Section 4](#4-making-a-release) and [Section 5](#5-publishing-to-pubdev--one-time-setup), recreate and push the release tag. For example, for version `5.0.11`:

```bash
./release-version 5.0.11
```

This helper script deletes the local and remote tag if they already exist, recreates `v5.0.11`, and pushes it to `origin`.

If you prefer the manual commands, the equivalent is:

```bash
git tag -d v<VERSION>
git push origin --delete v<VERSION>
git tag v<VERSION>
git push origin v<VERSION>
```

This automatically triggers the **Publish to pub.dev** workflow which:
1. Runs formatting check, analysis, and all tests
2. Publishes the package to pub.dev via OIDC
3. Creates a GitHub Release with the tag name and changelog notes extracted from `CHANGELOG.md`

Monitor the run at:
`https://github.com/mapp-digital/Mapp-Intelligence-Flutter-Tracking/actions`

---

## 7. Verifying the Publish Workflow Locally

The OIDC publish step requires GitHub's infrastructure and cannot be replicated locally. Every other step can be verified:

```bash
# Formatting
dart format --output=none --set-exit-if-changed lib/

# Static analysis
flutter analyze --no-fatal-infos

# Tests
flutter test

# Dry run — validates package structure without publishing
dart pub publish --dry-run
```

---

## 8. Troubleshooting

### "tag already exists"
```bash
./release-version <VERSION>
```

### pub.dev dry run fails
Run `dart pub publish --dry-run` locally to see exact issues. Common causes:
- `pubspec.yaml` version does not match the hardcoded version in `plugin_mappintelligence.dart`
- Missing required fields in `pubspec.yaml`
- Dart analysis errors

### GitHub Release has empty changelog
The version heading in `CHANGELOG.md` must match exactly `## <version>` with no `v` prefix (e.g. `## 5.0.11`, not `## v5.0.11`).

### OIDC authentication fails in CI
Verify the pub.dev admin setup in Section 5 is complete and the repository name matches exactly: `mapp-digital/Mapp-Intelligence-Flutter-Tracking`.

### Publish workflow triggers but GitHub Release is not created
The `github-release` job requires the `publish` job to succeed first. Check the Actions run log for errors in the publish step.
