# Repository Guidelines

## Project Structure & Module Organization
- `lib/` holds the Flutter/Dart application code (entry point is typically `lib/main.dart`).
- `test/` contains automated tests.
- `backend/` contains the Node.js + Express API (REST + SSE streaming).
- Platform targets live in `android/`, `ios/`, `web/`, `macos/`, `windows/`, and `linux/`.
- `build/` is generated output; do not edit by hand.
- `pubspec.yaml` declares dependencies, assets, and app metadata; `analysis_options.yaml` defines lint rules.
- `backend/.env.example` provides backend environment defaults.

## Where to Make Changes (Flutter vs Platform)
- Default: make UI/logic changes in `lib/` and run via `flutter run` / `flutter build <platform>`.
- Edit platform folders only for platform-specific configuration or native integrations (e.g., Android manifest, iOS entitlements, desktop network permissions).
- Never edit `build/` or generated files (Flutter/Gradle/Xcode outputs).

## Build, Test, and Development Commands
- `flutter pub get` installs Dart/Flutter dependencies.
- `flutter run` runs the app on a connected device or emulator.
- `flutter analyze` runs static analysis using the configured lints.
- `flutter test` runs the test suite (use `flutter test test/<file>_test.dart` to target a file).
- `flutter build <platform>` creates release builds, e.g. `flutter build apk`, `flutter build ios`, `flutter build web`.
- `cd backend && npm install` installs backend dependencies.
- `cd backend && npm run dev` runs the API with auto-reload.
- `cd backend && npm start` runs the API without auto-reload.
- `cd backend && npm test` runs backend Jest + SuperTest tests.
- VS Code uses `CMakePresets.json` plus `.vscode/` settings for auto-configuration.

## Coding Style & Naming Conventions
- Dart uses 2-space indentation; follow the default Dart formatter (`dart format .`).
- File names should be `lower_snake_case.dart`.
- Types and widgets use `UpperCamelCase`; variables, methods, and constants use `lowerCamelCase`.
- Lint rules are provided by `flutter_lints` and wired in `analysis_options.yaml`.
- State management uses Riverpod (Notifier-based providers in `lib/state/`).

## Testing Guidelines
- Use the `flutter_test` framework and place tests under `test/`.
- Name tests with the `*_test.dart` suffix.
- Prefer small unit tests and focused widget tests; keep tests deterministic.
- Optional coverage: `flutter test --coverage` (generates `coverage/`).
- Backend tests live in `backend/tests/` and use Jest/SuperTest.

## Backend API Notes
- REST: `POST /api/chat` accepts `{ "message": "..." }` and returns a full reply.
- Streaming: `POST /api/chat/stream` returns an SSE stream of reply chunks.
- Update backend config via `backend/.env` (copy from `backend/.env.example`).
- Set `GEMINI_API_KEY` in `backend/.env` (create one in Google AI Studio or Google Cloud Console).

## Deployment Notes
- Android: `flutter build apk`
- iOS: `flutter build ios` (requires Xcode and signing)
- macOS: `flutter build macos`

## Commit & Pull Request Guidelines
- Commit messages are short, imperative summaries (examples in history: "Add Windows support for personal AI assistant", "initialize workspace configuration file").
- Pull requests should include a brief summary, testing notes (commands run), and screenshots for UI changes when relevant.

## Configuration Tips
- If you add assets or fonts, register them under the `flutter:` section of `pubspec.yaml`.
- Use `--dart-define=API_BASE_URL=...` to point the Flutter app at non-localhost endpoints (Android emulator uses `http://10.0.2.2:3001`).
