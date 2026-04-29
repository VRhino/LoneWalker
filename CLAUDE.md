# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**LoneWalker** is a GPS-based exploration gamification mobile app (NestJS backend + Flutter frontend). Users explore cities to clear a "Fog of War" map, hunt for treasures with a radar system, and compete in rankings.

**Current state**: Phase 7 complete (Auth, Maps, Exploration, Treasure Hunt, Ranking, Landmarks, Medals). Phase 8 (Testing & Integration with Redis caching, offline mode, and fog degradation) is next.

## Commands

### Backend (`backend/`)

```bash
npm run start:dev        # Dev server with hot reload
npm run build            # Production build → dist/
npm run lint             # ESLint + auto-fix
npm run format           # Prettier
npm run test             # Jest unit tests
npm run test:watch       # Watch mode
npm run test:cov         # Coverage report
npm run test:e2e         # End-to-end tests
npm run db:migrate       # Run TypeORM migrations
npm run db:migration:create  # Create new migration
```

### Frontend (`frontend/`)

```bash
flutter pub get          # Install dependencies
flutter run              # Run on emulator/device
flutter analyze          # Static analysis
dart format .            # Format Dart code
flutter test             # Unit + widget tests
flutter test --coverage  # Coverage report
flutter build apk        # Android APK
```

### Local Services

```bash
docker-compose up -d postgres redis      # Start DB and cache
docker-compose --profile dev up -d       # Also starts pgAdmin
docker-compose down                      # Stop all
```

## Architecture

### Backend (NestJS + TypeScript)

Feature-modular structure under `backend/src/modules/`:
- `auth/` — JWT + Passport strategy, login/register, refresh tokens
- `users/` — Profile management (service only, no controller yet)
- `exploration/` — Fog-of-war tracking, PostGIS spatial queries
- `treasures/` — Treasure placement, radar proximity, claim validation
- `landmarks/` — Community landmark proposals and voting system
- `ranking/` — Global, weekly, and district leaderboards
- `medals/` — Achievement definitions and unlock tracking

Each module follows NestJS conventions: `*.module.ts`, `*.service.ts`, `*.controller.ts`, `*.entity.ts`, `*.dto.ts`.

**Key files**: `src/main.ts` (bootstrap + Swagger at `/api/docs`), `src/app.module.ts` (root imports), `src/config/database.config.ts` (TypeORM async config).

### Frontend (Flutter + Dart)

Clean architecture per feature under `frontend/lib/features/`:
- `auth/` — Login/register screens and BLoC
- `map/` — Google Maps integration, exploration overlay, fog-of-war
- `treasure/` — Radar UI, claim flow
- `landmarks/` — Landmark proposals, voting, detail view
- `ranking/` — Global, weekly leaderboards
- `profile/` — Medal gallery

Each feature follows: `data/` (remote datasource, models) → `domain/` (entities, repository interfaces) → `presentation/` (BLoC events/states, pages, widgets).

**State management**: BLoC pattern exclusively. Shared utilities and theme in `lib/core/`.

### Data Layer

- **PostgreSQL 14+** with PostGIS extension for geospatial queries (exploration tiles, treasure proximity)
- **Redis 7+** — dependency installed, integration pending (Phase 8)
- **SQLite (Drift)** — dependency installed, offline sync pending (Phase 8)
- **TypeORM** with entity-based ORM; `synchronize: true` in dev only — use migrations in production

### Auth Flow

JWT (`HS256`, 1h access / 7d refresh). Backend guards use Passport. Custom `@CurrentUser()` decorator extracts user from JWT header. All protected routes require `JwtAuthGuard`.

### Exploration Flow

GPS position → velocity check (>20 km/h blocked) → GPS point registered (15m FOW radius per point) → server sync when online. Offline mode and local SQLite sync are pending implementation (Phase 8).

### Treasure Hunt Flow

POI approach (<75m) → radar activates → within 10m shows "Claim" button → GPS validated 3–5s → server records claim and awards XP.

## Key Conventions

- **2 spaces** indentation, **single quotes**, **trailing commas**, **LF** line endings (see `.editorconfig`)
- Global `ValidationPipe` with `whitelist: true, forbidNonWhitelisted: true` — DTOs must be complete
- Environment config via `.env` (copy from `.env.example`); never hardcode secrets
- Swagger docs auto-generated — keep controller decorators (`@ApiOperation`, `@ApiResponse`) up to date
- PostGIS queries go in the relevant module's service, not raw SQL elsewhere

## Documentation

`Docs/` contains architecture diagrams, API reference, and the 8-phase `DEVELOPMENT_PLAN.md`. Written in Spanish. `Docs/LOCAL_SETUP.md` has full setup instructions.
