# Flutter Package Rules

## Scope

These instructions apply to the whole repository.

## Project Type

- This repository is a Flutter plugin package, not a standalone app.
- Treat `lib/` as the published package surface.
- Treat `example/` as a consumer app used for manual validation and analyzer coverage.
- Keep Android and iOS plugin implementations aligned with Dart API changes.

## Working Style

- Prefer small, targeted changes over broad refactors.
- Preserve the public API unless the task explicitly requires a breaking change.
- Do not change package name, plugin class names, or platform package identifiers unless explicitly requested.
- When touching generated or vendored content, stop and confirm first unless the change is clearly required by the task.

## Validation

- Prefer these checks after code changes:
  - `flutter analyze --no-fatal-infos`
  - `flutter test`
- For runtime regression work, prefer the example smoke test:
  - `cd example && flutter test integration_test/app_smoke_test.dart -d <DEVICE_ID>`
- If you only changed package Dart code, still consider analyzer impact on `example/`.
- If you change CI behavior, check `.github/workflows/validate.yml`.
- If you change publish behavior, check `.github/workflows/publish.yml`.

## Formatting

- Format changed Dart files with `dart format`.
- Do not reformat unrelated files.

## Package API Changes

- When changing code in `lib/plugin_mappintelligence.dart`, verify that the README examples still match the API.
- Keep method names and parameter behavior consistent across Dart and native layers.
- Favor backward-compatible additions over signature changes.

## Versioning

- `pubspec.yaml` version must stay in sync with the version constant in `lib/plugin_mappintelligence.dart`.
- If a task changes the package version, update both places in the same change.
- Do not bump versions unless the user asks or the task clearly requires it.

## Example App

- Keep the example app buildable and analyzable.
- Prefer minimal demo-oriented fixes in `example/`; avoid production-grade abstractions there unless requested.
- If a dependency API deprecates, update the example usage when it is easy and low-risk.
- Android example smoke coverage exists in `example/integration_test/app_smoke_test.dart`; keep it stable when changing example navigation or consent flow.
- iOS runtime smoke coverage is not automated yet; do not claim parity unless it was explicitly tested.
- Do not assume example integration tests can be enforced in CI; org action policy may require them to stay as local/manual checks.

## Analyzer Hygiene

- Avoid introducing new warnings in `example/` or `lib/`.
- Keep generated/build/SDK directories excluded from analyzer scope through repo config rather than ad hoc workarounds.

## Native Code

- For Android changes, inspect `android/src/main/kotlin/...`.
- For iOS changes, inspect `ios/Classes/...` and the bundled framework interface if needed.
- Keep platform channel names, argument keys, and serialization behavior consistent across Dart and native code.

## Dependencies

- Do not add new package dependencies unless necessary for the task.
- Prefer upgrading usage patterns before adding compatibility wrappers.
- If dependency changes are required, update the smallest relevant set of files.

## Documentation

- Update `README.md` when user-facing setup, API usage, or behavior changes.
- Keep README snippets aligned with the current API and package initialization flow.

## CI Notes

- CI installs Flutter during workflow execution; do not assume a checked-in SDK should be analyzed as part of the package.
- Prefer workflow changes that keep the repository root clean and avoid polluting analyzer input.
