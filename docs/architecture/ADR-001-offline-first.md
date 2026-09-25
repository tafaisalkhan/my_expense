# ADR-001: Offline-First Architecture & Local Database Choice

## Context
MyExpense must function reliably in offline environments. All financial entries, category configurations, family profiles, analytics, search, and history must function without network availability.

## Decision
We adopt SQLite via `sqflite` (with `sqflite_common_ffi` for desktop testing) as the single source of truth for persistent local data. All UI interaction queries read directly from local repositories powered by SQLite. Remote sync (when added in Phase 6) will act as an asynchronous replication layer, keeping SQLite as the local primary storage.

## Consequences
- No network dependency for any core product workflow.
- High speed and responsiveness for queries and aggregation.
- Schema changes require versioned SQLite database migration scripts (`V1`, `V2`, etc.).
