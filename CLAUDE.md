# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Serv Ease is a customer support application with four components:

- **Flutter app** (`lib/`) — iOS/Android/macOS/Web client for end users. Feature-based structure with bloc/cubit state management and repository pattern for data access.
- **NestJS server** (`server/`) — REST API backend with Prisma ORM, PostgreSQL, JWT auth with refresh tokens, and PM2-based deployment.
- **Admin web** (`admin-web/`) — React + Vite admin panel using Ant Design, React Router 7, Zustand for auth state, and TanStack Query for server state.
- **iOS native app** (`ios_native_app/`) — Separate native iOS wrapper (ServEaseApp).

The project follows the "FAQ + Ticket + Contact Support" product plan (方案 A in `项目规划.md`). The MVP includes FAQ browsing, ticket creation/tracking, push notifications, and an admin backoffice for agent ticket management.

## Common Commands

### Flutter app

```bash
flutter pub get                    # Install dependencies
flutter analyze                    # Static analysis (uses flutter_lints)
dart format lib test               # Format Dart code
flutter test                       # Run all tests
flutter run -d macos               # Run on macOS
flutter run -d chrome              # Run on Chrome
```

### Server (NestJS + Prisma)

```bash
cd server
npm install                        # Install dependencies
npm run dev                        # Start dev server with watch (port 3001)
npm run build                      # Production build (nest build)
npm run lint                       # ESLint
npm run format                     # Prettier
npx prisma generate                # Regenerate Prisma client
npx prisma migrate dev             # Run migrations in dev
npx prisma studio                  # Open Prisma Studio DB browser
npm run check                      # Full check: prisma generate + build
```

Required env vars: `DATABASE_URL`, `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET`. Optionally `PORT` (default 3001), `API_PREFIX` (default `v1`).

### Admin web

```bash
cd admin-web
npm install                        # Install dependencies
cp .env.example .env               # Set up env (API base URL defaults to http://localhost:3001/v1)
npm run dev                        # Vite dev server (default http://localhost:5174)
npm run build                      # TypeScript check + Vite production build
npm run lint                       # tsc --noEmit type check
```

Test accounts: `admin@163.com` / `123456789` (ADMIN), or create via `/auth/register`.

### Deploy

```bash
./deploy-server.sh                 # Interactive deploy to 47.82.121.213 via SSH + PM2
```

The script pushes local commits, SSHs to the server, pulls, installs deps, runs Prisma migrations, builds, and restarts the PM2 process.

## Architecture

### Flutter app (`lib/`)

The app uses **feature-based architecture** with [flutter_bloc](https://pub.dev/packages/flutter_bloc) for state management and the repository pattern for data access.

```
lib/
  main.dart                          # Entry point — WidgetsFlutterBinding + runApp
  app/
    app.dart                         # ServEaseApp root widget, DI wiring, MultiBlocProvider setup
    app_shell.dart                   # Bottom nav shell (FAQs / Tickets / Notifications), role-gated menu
    app_theme.dart                   # Light theme per DESIGN.md
  core/
    config/app_config.dart           # API_BASE_URL from env (default: production server)
    localization/                    # LocaleCubit, i18n extension
    network/api_client.dart          # HTTP client with auto token refresh, unified error handling
    session/                         # SessionCubit (auth state), SessionStore (token persistence)
    widgets/                         # Shared widgets: SurfaceCard, PrimaryPillButton, EmptyStateCard
  features/
    auth/                            # Login (email-based)
    faqs/                            # Public FAQ browsing
    tickets/                         # Ticket CRUD, list, detail, create
    notifications/                   # Push notification list with unread badge
    admin_faqs/                      # Agent/Admin FAQ management (CRUD categories & entries)
    settings/                        # Settings screen with logout
  l10n/                              # AppLocalizations (en, zh) with code generation
```

**State management pattern**: Each feature has a Cubit (e.g., `TicketListCubit`) that depends on a Repository class. Repositories depend on `ApiClient`. The `ApiClient` handles Bearer tokens, auto-refresh on 401, and unwraps the `{ success, data, error }` response envelope.

**API response envelope**: All server responses follow `{ success: boolean, data?: T, error?: { code, message } }`. The `ApiClient._unwrap()` method throws `ApiException` on `success: false` and extracts `data` on success.

### NestJS server (`server/`)

Modular NestJS architecture with global validation, exception filtering, and response transformation.

```
server/src/
  main.ts                           # Bootstrap: CORS, global prefix, pipes, interceptors, filters
  app.module.ts                     # Root module importing all feature modules
  config/                           # appConfig (env mapping), env schema validation
  prisma/                           # PrismaModule + PrismaService (global)
  common/                           # JwtAuthGuard, CurrentUser decorator, enums, pagination DTO
  common/interceptors/              # ResponseInterceptor (wraps in {success,data}), AccessLogInterceptor
  common/exceptions/                # AppExceptionFilter
  common/logger/                    # LoggerModule + LoggerService
  auth/                             # JWT auth: register, login, refresh, logout
  users/                            # User profile, delete account
  faqs/                             # Public FAQ listing (categories + entries)
  tickets/                          # Ticket CRUD, reply, close, status transitions
  admin/                            # Admin endpoints: manage FAQs, tickets, agents, logs
  uploads/                          # File upload with multipart upload
  notifications/                    # Notification list, push device registration
  health/                           # Health check endpoint
```

**Key patterns**:
- All responses go through `ResponseInterceptor` which wraps them in `{ success: true, data }`.
- `AppExceptionFilter` catches all exceptions and returns `{ success: false, error: { code, message } }`.
- `ValidationPipe` with `whitelist: true, forbidNonWhitelisted: true` on all routes.
- DTOs use `class-validator` decorators for request validation.
- `AccessLogInterceptor` logs every request via `LoggerService`.

### Admin web (`admin-web/`)

React SPA with file-based module organization.

```
admin-web/src/
  main.tsx                          # Entry point
  app/
    App.tsx                         # Root with QueryClientProvider, RouterProvider
    providers.tsx                   # QueryClient + AuthProvider wrapper
    router.tsx                      # All routes (login, faqs, categories, tickets, logs)
    AdminLayout.tsx                 # Ant Design sidebar layout
  modules/
    auth/                           # Login page, RequireAuth guard, Zustand auth store
    faqs/                           # FAQ list + form pages, API calls via axios
    faq-categories/                 # Category list + form pages
    tickets/                        # Ticket list + detail pages with search/filter/history
    logs/                           # Access log viewer
  shared/
    api/client.ts                   # Axios instance with Bearer token interceptor
    api/types.ts                    # Shared TypeScript types
    session/storage.ts              # Token persistence in localStorage
```

**State management**: Zustand for auth state (token storage + user info), TanStack Query (React Query v5) for server data fetching/mutations, React Router v7 for routing.

### Database (Prisma / PostgreSQL)

Key models: `User`, `UserSession`, `Ticket`, `TicketMessage`, `TicketAttachment`, `TicketHistory`, `FaqCategory`, `Faq`, `Notification`, `PushDevice`.

Enums: `UserRole` (USER/AGENT/ADMIN), `UserStatus` (ACTIVE/DISABLED/DELETED), `TicketStatus` (OPEN/PENDING/IN_PROGRESS/RESOLVED/CLOSED), `TicketPriority` (LOW/NORMAL/HIGH/URGENT), `TicketHistoryAction` (CREATED/STATUS_CHANGED/ASSIGNED/REPLIED/CLOSED/REOPENED etc.).

## Design Context

`DESIGN.md` is the source of truth for UI implementation. Core rules:

- **Background**: Cloud Gray (`#f0f0f3`) page, Pure White (`#ffffff`) cards
- **Typography**: Inter at weights 400–900, extreme negative letter-spacing on large headlines
- **Geometry**: Pill-shaped buttons (9999px radius), comfortably rounded cards (8px), no sharp corners
- **Color**: Strictly monochrome — `#000000` headlines, `#60646c` secondary text, `#0d74ce` links. No decorative color; product screenshots provide visual richness.
- **Spacing**: Enormous vertical rhythm (96px+ between sections), 8px base unit
- **Shadows**: Whisper-soft — depth comes from background contrast, not heavy shadows

The Flutter `AppTheme` already implements these values. Import from `app/app_theme.dart` for shared constants.

## Important Notes

- The working directory path contains a trailing space. Use `cd "$(pwd)"` prefix for find/xargs commands, or quote paths.
- `.qoder/rules/rules.md` references the `karpathy-guidelines` skill — apply it when writing or reviewing code.
- The `flutter_lints` package (v6) provides lint rules via `analysis_options.yaml`.
- The production server is at `47.82.121.213:3001/v1/`. The Flutter app defaults to this; admin-web defaults to `localhost:3001/v1`.
