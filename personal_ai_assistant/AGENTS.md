# Repository Guidelines

## Project Structure & Module Organization
- `lib/` holds the Flutter/Dart application code (entry point is typically `lib/main.dart`).
- `test/` contains automated tests.
- Platform targets live in `android/`, `ios/`, `web/`, `macos/`, `windows/`, and `linux/`.
- `build/` is generated output; do not edit by hand.
- `pubspec.yaml` declares dependencies, assets, and app metadata; `analysis_options.yaml` defines lint rules.

## Build, Test, and Development Commands
- `flutter pub get` installs Dart/Flutter dependencies.
- `flutter run` runs the app on a connected device or emulator.
- `flutter analyze` runs static analysis using the configured lints.
- `flutter test` runs the test suite (use `flutter test test/<file>_test.dart` to target a file).
- `flutter build <platform>` creates release builds, e.g. `flutter build apk`, `flutter build ios`, `flutter build web`.

## Coding Style & Naming Conventions
- Dart uses 2-space indentation; follow the default Dart formatter (`dart format .`).
- File names should be `lower_snake_case.dart`.
- Types and widgets use `UpperCamelCase`; variables, methods, and constants use `lowerCamelCase`.
- Lint rules are provided by `flutter_lints` and wired in `analysis_options.yaml`.

## Testing Guidelines
- Use the `flutter_test` framework and place tests under `test/`.
- Name tests with the `*_test.dart` suffix.
- Prefer small unit tests and focused widget tests; keep tests deterministic.
- Optional coverage: `flutter test --coverage` (generates `coverage/`).

## Commit & Pull Request Guidelines
- Commit messages are short, imperative summaries (examples in history: "Add Windows support for personal AI assistant", "initialize workspace configuration file").
- Pull requests should include a brief summary, testing notes (commands run), and screenshots for UI changes when relevant.

## Configuration Tips
- If you add assets or fonts, register them under the `flutter:` section of `pubspec.yaml`.
