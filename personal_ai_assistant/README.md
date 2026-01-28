# Personal AI Assistant

## Architecture Overview
- Flutter frontend lives in `lib/` with Riverpod state management and a basic chat UI screen (`lib/screens/chat_screen.dart`).
- Navigation is configured in `lib/main.dart` using named routes.
- Node.js backend lives in `backend/` and exposes a REST endpoint at `/api/chat` plus a WebSocket at `/ws` for streaming replies.
- Environment examples live in `backend/.env.example` (copy to `backend/.env` for local use).

## Local Development

### Flutter App
```bash
flutter pub get
flutter run
```

### Node.js Backend
```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

The API will be available at `http://localhost:3001/api/chat` by default. Update `PORT` in `backend/.env` if needed.
The WebSocket endpoint is `ws://localhost:3001/ws` and streams reply chunks.

## Folder Structure
```
lib/        # Flutter app code (chat UI)
test/       # Flutter tests
backend/    # Node.js + Express API
```
