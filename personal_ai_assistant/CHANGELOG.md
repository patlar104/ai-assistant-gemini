# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
- Document any upcoming changes here.

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
