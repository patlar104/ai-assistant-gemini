# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
### Changed
- Clarified Flutter-first edit guidance in `AGENTS.md`.

### Fixed
- Avoided web SSE error handling crashes when error events lack message payloads.
- Closed stale streaming assistant messages when streams are restarted or fail.
- Limited Android cleartext traffic config to debug/profile builds only.
- Ensured SSE streaming emits in-band error events for missing messages on web.

## [2026-01-28]
### Added
- Flutter chat UI with navigation and Riverpod state management.
- Node.js backend with Express, REST `/api/chat`, and SSE streaming at `/api/chat/stream`.
- Backend environment example in `backend/.env.example`.
- Contributor guidelines in `AGENTS.md`.

### Changed
- Replaced WebSocket streaming with REST + SSE.
- Updated widget test to cover chat navigation and UI.
- Expanded `.gitignore` to cover Node.js artifacts and env files.

### Fixed
- macOS network entitlement for local API connections.
