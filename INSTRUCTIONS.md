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
7. [Verifying the Publish Workflows Locally](#7-verifying-the-publish-workflows-locally)
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

**Version sync test** — one test specifically reads `pubspec.yaml` at runtime and asserts it matches the hardcoded version string in `lib/plugin_mappintelligence.dart`. This will fail if you bump one but forget the other:

```
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
version: 5.0.11
```

### Step 2 — Update version in `lib/plugin_mappintelligence.dart`
Find `_updateCustomParams()` and update the hardcoded string to match:
```dart
final flutterPluginVersion = "5.0.11";
```

### Step 3 — Update `CHANGELOG.md`
Add a new section at the top:
```markdown
## 5.0.11
- Description of changes
```

### Step 4 — Run the version sync test to confirm both versions match
```bash
flutter test --name "version sync"
```

### Step 5 — Run all tests
```bash
flutter test
```

### Step 6 — Run a publish dry run to catch any packaging issues
```bash
dart pub publish --dry-run
```

### Step 7 — Commit and push to `main`
```bash
git add -A
git commit -m "chore: release 5.0.11"
git push origin main
```

The `validate.yml` GitHub Actions workflow will automatically run all tests and a dry run on push to `main`. Wait for it to pass before proceeding.

---

## 5. Publishing to pub.dev — One-Time Setup

This only needs to be done once per package. It authorizes GitHub Actions to publish using OIDC (no credentials or tokens required).

### Step 1 — Enable automated publishing on pub.dev

1. Go to `https://pub.dev/packages/plugin_mappintelligence/admin`
2. Sign in with the account that owns the package
3. Scroll to **Automated publishing**
4. Click **Enable publishing from GitHub Actions**
5. Fill in:
   - **Repository:** `mapp-digital/Mapp-Intelligence-Flutter-Tracking`
   - **Tag pattern:** `v{{version}}`
6. Enable the **"Allow workflow_dispatch"** checkbox
7. Click **Save**

### Step 2 — Verify the GitHub Actions workflows are present

Confirm these three files exist in the repository:

```
.github/workflows/validate.yml       ← runs on every push to main / PR
.github/workflows/tag-release.yml    ← creates a git tag from the web UI
.github/workflows/publish.yml        ← publishes to pub.dev when tag is pushed
```

No secrets or tokens need to be added to the repository. Authentication is handled automatically via OIDC.

---

## 6. Publishing a New Version

After completing [Section 4](#4-making-a-release) and [Section 5](#5-publishing-to-pubdev--one-time-setup):

### Option A — Trigger from GitHub web UI (recommended)

1. Go to the repository on GitHub
2. Click **Actions** tab
3. Select **Tag and Release** workflow from the left sidebar
4. Click **Run workflow**
5. Enter the version number (e.g. `5.0.11`) — must match `pubspec.yaml` exactly
6. Click **Run workflow**

This will:
- Validate the version matches `pubspec.yaml`
- Create and push git tag `v5.0.11`
- Automatically trigger the **Publish to pub.dev** workflow
- Run all tests, then publish the package

### Option B — Trigger manually from the terminal

```bash
git tag v5.0.11
git push origin v5.0.11
```

This triggers the **Publish to pub.dev** workflow directly.

### Monitor the publish

Go to `https://github.com/mapp-digital/Mapp-Intelligence-Flutter-Tracking/actions` to watch the workflow run. A successful run means the package is live on pub.dev within a few minutes.

---

## 7. Verifying the Publish Workflows Locally

The actual OIDC publish step requires GitHub's infrastructure and cannot be fully replicated locally. However, every other step can be verified:

### Verify formatting
```bash
dart format --output=none --set-exit-if-changed lib/
```

### Verify static analysis
```bash
flutter analyze --no-fatal-infos
```

### Verify tests pass
```bash
flutter test
```

### Verify the package is publishable (dry run)
```bash
dart pub publish --dry-run
```

A successful dry run means the package structure, `pubspec.yaml`, and all required fields are valid. The only step that cannot be tested locally is the OIDC authentication handshake with pub.dev — this is verified by the one-time setup in Section 5.

### Verify the tag-release workflow logic manually
```bash
# Simulate what tag-release.yml does:
PUBSPEC_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
echo "pubspec.yaml version: $PUBSPEC_VERSION"
# Confirm the tag does not already exist:
git tag | grep "v$PUBSPEC_VERSION"
```

---

## 8. Troubleshooting

### "Version mismatch" error in Tag and Release workflow
The version you entered does not match `pubspec.yaml`. Update `pubspec.yaml` and push to `main` before triggering the workflow.

### "publishing is not allowed from workflow_dispatch events"
The **"Allow workflow_dispatch"** checkbox is not enabled on pub.dev. Go to `pub.dev/packages/plugin_mappintelligence/admin` and enable it.

### "publishing is only allowed from tag refType"
The publish workflow was triggered on a branch ref, not a tag. This happens if you manually trigger `publish.yml` from a branch. Always use `tag-release.yml` to create the tag first, or trigger `publish.yml` only after the tag exists.

### "tag already exists"
```bash
# Delete local tag
git tag -d v5.0.11
# Delete remote tag (use with caution)
git push origin --delete v5.0.11
```

### pub.dev dry run fails with "7 issues found"
Run `dart pub publish --dry-run` locally to see the exact issues. Common causes:
- Missing `description` in `pubspec.yaml`
- Files referenced in `pubspec.yaml` that don't exist
- Dart files with analysis errors

### OIDC authentication fails in CI
Verify the pub.dev admin setup in Section 5 is complete and the repository name matches exactly (`mapp-digital/Mapp-Intelligence-Flutter-Tracking`).
