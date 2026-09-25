# MyExpense Project State

## Project Overview
**MyExpense** is an intelligent, offline-first personal and family expense-management mobile application built with Flutter, SQLite, Riverpod, GoRouter, and Clean Architecture.

---

## Current Status
- **Current Phase**: Phase 4 — Documents & Share Target (Shared Receipt Attachment Enabled)
- **Current Feature**: Free Shared Receipt Attachment, Premium OCR Gating, Budgets, Calendar, Reports & Subscriptions
- **Database Version**: 3

---

## Completed Features
- [x] Initialized Flutter application structure (`myexpence`)
- [x] Added dependencies (`flutter_riverpod`, `sqflite`, `go_router`, `intl`, `uuid`, `fl_chart`, `path_provider`, `shared_preferences`, `flutter_local_notifications`, `sqflite_common_ffi`)
- [x] Setup Feature-First Clean Architecture folder structure (`core/`, `features/`)
- [x] Default Categories JSON asset (`assets/config/default_categories.json`)
- [x] SQLite Database Provider & Migrations framework (`V1_initial_schema`, `V2_add_budgets`, `V3_add_receipts`)
- [x] Domain Models (`Expense`, `Person`, `Category`, `Subcategory`, `Budget`, `Receipt`, `UserSubscription`, `ExpenseClassification`, `PaymentMethod`, `ExpenseStatus`)
- [x] Mandatory separation of `expenseDate` (transaction date) vs `createdAt` (system creation timestamp)
- [x] Family / Person Entity Model independent from category taxonomy
- [x] Clean Architecture Repositories: `SqliteExpenseRepository`, `SqlitePersonRepository`, `SqliteCategoryRepository`, `SqliteBudgetRepository`, `SqliteReceiptRepository`
- [x] Free Shared Receipt Attachment: Free users can share/receive receipt photos & fee vouchers, view slip preview side-by-side, and enter expense details manually.
- [x] Premium OCR Text Parsing Gating: Upgrade banner for automatic OCR item extraction.
- [x] Monthly ($2.99/mo) & Yearly ($15.00/yr - Save 58%) Premium Subscriptions with 7-Day Free Trial
- [x] Premium Only Badges for Encrypted Cloud Sync & Backup
- [x] Interactive Expense Calendar (`/calendar`): Grid view showing spend recorded days, zero-spend confirmed days, missing/unconfirmed days, and future dates
- [x] Multi-Source Receipt Attachment & Strict File Validation: Added Camera photo capture, Gallery image picking, and PDF document sharing support. Strictly enforces file type validation allowing ONLY Images (`.jpg`, `.jpeg`, `.png`, `.webp`, `.heic`) and PDF documents (`.pdf`), rejecting unsupported files (`.docx`, `.mp4`, `.zip`) with a user alert.
- [x] Intelligent Receipt OCR Scanner: `OcrScannerService` parses attached camera photos, gallery images, and PDF slip receipts to extract merchant names, total amounts, date, line items, and auto-map categories (`/share-receipt`).
- [x] Smart Geofencing & Location Reminders Engine: Implemented `LocationNotificationNotifier` (`/location-notifications`) detecting when users leave commercial locations (Mart, Hospital, Petrol Pump, Mall, Restaurant) with hourly reminder follow-ups, Mute Place functionality, Discard visit action, support for multiple daily visits, and automatic daily midnight reset (no carry over to previous days). Integrated `LocationPermissionService` for safe location tracking and permission handling.
- [x] Location Notifications Screen Layout Fix: Refactored custom location input form into clean vertical column structure and updated action buttons (`Discard`, `Mute Place`, `Log Expense`) to responsive `Wrap` layout, eliminating right horizontal screen overflow.
- [x] SMS Transaction Parser (`/share-sms`): Parses bank and vendor SMS notifications to extract debited amounts, merchants, dates, and auto-classifies into Required vs Optional expenses.
- [x] 1-Tap Google Account Sign-In: Direct Google OAuth login (`/login`) with Firebase Project (`myexpenses-d3cb0`) credentials integration, complete `.gitignore` private key protection, and zero manual email input required.
- [x] Unit & Repository Tests: 100% passing tests across 28 test cases.

---

## Architecture Decisions (ADRs)
- `ADR-001`: Offline-First Architecture & SQLite Local Storage
- `ADR-002`: Expense Date vs Created Date Separation
- `ADR-003`: Family Person Entity Model (Independent from Categories)
- `ADR-004`: Recurring Expense Idempotency Strategy
- `ADR-005`: Intelligent Document Processing & OCR Review Pipeline
- `ADR-006`: Local Privacy vs Cloud Sync Readiness

---

## Tests Status
- `receipt_repository_test.dart`: PASSED
  - Save and retrieve shared receipt slip image details: PASSED
- `subscription_test.dart`: PASSED
  - Free tier default state: PASSED
  - Monthly subscription ($2.99): PASSED
  - Yearly subscription ($15.00): PASSED
  - 3-Month Free Promo Code Redemption (90 Days): PASSED
- `budget_repository_test.dart`: PASSED
  - Set and retrieve monthly and category budgets: PASSED
  - Budget upserts without duplicates: PASSED
- `category_repository_test.dart`: PASSED
  - Add custom category and custom subcategory: PASSED
- `expense_repository_test.dart`: PASSED
  - Backdated expense counts against `expenseDate` and NOT `createdAt`: PASSED
  - Soft delete removes entry from totals: PASSED
  - Zero-spend day confirmation: PASSED
- `location_notification_test.dart`: PASSED
  - OCR extracts merchant, amount, date, line items, and category mapping: PASSED
  - Strict file type validation (Images & PDFs only): PASSED
  - Multiple location visits in 1 day produce 3 distinct notifications: PASSED
  - Muted location suppresses future notifications: PASSED
  - Discarding clears visit but permits future visits today: PASSED
  - Daily expiry reset (no previous day carry over): PASSED
- `widget_test.dart`: PASSED
  - MyExpense app initialization: PASSED

---

## Next Tasks
1. **Phase 3 — Recurring Expenses**: Recurrence rules (daily, weekly, monthly, custom), auto-approve / manual approval modes, habit reminders, duplicate-safe occurrence generation.
2. **Phase 5 — Advanced Intelligence**: Inflation assumptions, planned expense planner.
3. **Phase 6 — Security & Cloud Sync**: Biometric security, local JSON backup & restore, CSV export, cloud sync plugin.
