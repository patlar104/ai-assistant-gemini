# Personal AI Assistant

## Architecture Overview
- Flutter frontend lives in `lib/` with Riverpod state management and a basic chat UI screen (`lib/screens/chat_screen.dart`).
- Navigation is configured in `lib/main.dart` using named routes.
- Node.js backend lives in `backend/` and exposes a REST endpoint at `/api/chat` plus an SSE stream at `/api/chat/stream` for streaming replies.
- Environment examples live in `backend/.env.example` (copy to `backend/.env` for local use).

## Local Development

### Environment Setup
1. Copy `backend/.env.example` to `backend/.env`.
2. Add a Gemini API key (create one in Google AI Studio or Google Cloud Console) as `GEMINI_API_KEY`.
3. Set `API_BASE_URL` for Flutter when running on devices or emulators.

### Flutter App
```bash
flutter pub get
flutter run
```
Use a custom API base URL when needed:
```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3001
```
Android emulator uses `http://10.0.2.2:3001`. iOS simulator can use `http://localhost:3001`.

### Node.js Backend
```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

The API will be available at `http://localhost:3001/api/chat` by default. Update `PORT` in `backend/.env` if needed.
The SSE endpoint is `http://localhost:3001/api/chat/stream` and streams reply chunks.

## Testing
```bash
flutter test
cd backend && npm test
```

## Deployment
### Android
```bash
flutter build apk
```

### iOS
```bash
flutter build ios
```
Requires Xcode and a configured signing team in the iOS project.

### macOS
```bash
flutter build macos
```

## Folder Structure
```
lib/        # Flutter app code (chat UI)
test/       # Flutter tests
backend/    # Node.js + Express API
```
