# MyExpense Project State

## Project Overview
**MyExpense** is an intelligent, offline-first personal and family expense-management mobile application built with Flutter, SQLite, Riverpod, GoRouter, and Clean Architecture.

---

## Current Status
- **Current Phase**: Phase 4 — Multi-Section OCR Scanner, Live SMS Listener, Interactive OpenStreetMap Geofencing & Google Play Compliance
- **Database Version**: 3
- **Git Repository**: `https://github.com/tafaisalkhan/my_expense.git` (Branch: `main`)

---

## Completed Features

### 1. Core Architecture & Offline Storage
- [x] Initialized Flutter application structure (`myexpence`) with Clean Architecture (`core/`, `features/`).
- [x] Feature-First folder hierarchy: Expenses, Categories, Budgets, Calendar, Document Scanner, Notifications, People, Receipts, SMS Parser, Subscription.
- [x] SQLite Database & Migrations framework (`V1_initial_schema`, `V2_add_budgets`, `V3_add_receipts`).
- [x] Clean Architecture Repositories: `SqliteExpenseRepository`, `SqlitePersonRepository`, `SqliteCategoryRepository`, `SqliteBudgetRepository`, `SqliteReceiptRepository`.
- [x] Mandatory separation of `expenseDate` (transaction date) vs `createdAt` (system record creation timestamp).
- [x] Independent Family / Person Entity Model decoupled from category taxonomy.

### 2. Multi-Section OCR Receipt Scanner & Document Processing
- [x] **Multi-Section Receipt Scanning**: `OcrScannerService.scanMultipleReceipts()` enables capturing 2 or 3 photos (Top, Middle, Bottom) for long/tall store receipts, automatically stitching items and aggregating total amounts.
- [x] **Clean Spatial Line Parsing**: Reverted line item extraction to the spatial regex line algorithm (`itemLineRegExp`), supporting multi-section receipt parsing, merchant detection, date extraction, and exact time extraction (`timeString`, `fullDateTime`).
- [x] **Per-Item Customization Modal**: Tapping any scanned item on `ShareDocumentReviewScreen` opens an interactive dialog to edit item name, unit price, quantity, category, classification (*Required / Optional / Investment*), and family member tag.
- [x] **Strict File Validation**: Supports Camera capture, Gallery picker, and PDF document files, rejecting non-supported formats (`.docx`, `.mp4`, `.zip`).

### 3. Live Native SMS Listener & Transaction Parser
- [x] **Native Android Receiver**: Kotlin `SmsReceiver.kt` BroadcastReceiver and `MainActivity.kt` channel setup to capture live bank SMS notifications.
- [x] **Live Flutter Listener**: `SmsListenerService` listens for incoming bank transaction messages and auto-prepares draft expense entries.
- [x] **SMS Categorizer Screen**: `/share-sms` parses bank and vendor SMS alerts, extracting amounts, merchants, dates, and classifying items into Required vs Optional expenses.

### 4. Interactive OpenStreetMap Geofencing & Map Notifications
- [x] **Real Map Location Picker**: Interactive OpenStreetMap interface (`GeofenceMapScreen`) with zoom, recenter GPS location, and radius slider (10m - 1000m).
- [x] **1-Tap Marker Expense Creator**: Tapping any map pin (Petrol Station, Supermarket, Market, custom pin) opens a bottom sheet with a 1-tap **"➕ Add Expense for [Marker Title]"** button pre-filling category, merchant name, and location details.
- [x] **Smart Geofence Notifications**: Triggers local alerts when users leave designated commercial zones, supporting hourly follow-ups, Mute Place functionality, Discard visit action, and daily midnight expiry reset.

### 5. Subscription, Calendar & Authentication
- [x] **Subscriptions & Upgrades**: Monthly ($2.99/mo) and Yearly ($15.00/yr) Premium plans, 7-Day Free Trial, and 90-Day Promo Code redemption.
- [x] **Interactive Expense Calendar**: `/calendar` grid view displaying spend days, zero-spend confirmed days, missing days, and future dates.
- [x] **Google Account Sign-In**: Direct OAuth login (`/login`) with Firebase Project (`myexpenses-d3cb0`) setup.

---

## Data Safety & Google Play Compliance
- [x] **`private.md` & `privacy_policy.md`**: Detailed markdown privacy disclosure covering Camera, Storage, SMS, Location, and Local Storage.
- [x] **`private.html` & `privacy_policy.html`**: Styled HTML Privacy Policy web pages for Play Console listing.
- [x] **`PLAY_STORE_DATA_SAFETY.md`**: Complete Google Play Store Data Safety section form responses and permission justification guide.

---

## Test Suite Execution Summary
**All 33 unit and widget tests pass with 0 errors:**
1. `auth_test.dart`: PASSED (Google Auth state, email validation, sign out)
2. `budget_repository_test.dart`: PASSED (Monthly/category budgets, upserts)
3. `category_repository_test.dart`: PASSED (Custom categories & subcategories)
4. `expense_repository_test.dart`: PASSED (Backdated expenses, soft deletes, zero-spend confirmations)
5. `location_notification_test.dart`: PASSED (OCR extraction, strict file validation, geofence notification rules, muted locations, daily expiry resets)
6. `receipt_repository_test.dart`: PASSED (Receipt slip saving and retrieval)
7. `sms_parser_test.dart`: PASSED (Bank SMS debit card parsing, vendor classification, bank whitelist verification)
8. `subscription_test.dart`: PASSED (Free tier, trial, monthly/yearly plans, 90-day promo code)
9. `widget_test.dart`: PASSED (App initialization check)

---

## Next Planned Development Phases
1. **Phase 5 — Advanced Intelligence & Reports**: Planned expense planner, spending trend forecasts, category breakdown charts.
2. **Phase 6 — Security & Backup**: Biometric app lock, encrypted JSON backup & restore, CSV/PDF export options.
