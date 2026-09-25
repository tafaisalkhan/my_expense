# ADR-005: Intelligent Document Pipeline & OCR Review

## Context
Scanning bills, receipts, and school vouchers via camera, gallery, or Android/iOS share intents reduces data entry friction. However, OCR engines occasionally misread numbers, merchant names, or dates.

## Decision
1. Scanned documents follow a multi-stage pipeline: `File Input -> Preprocess -> Text Extraction -> Entity Matching -> Duplicate Check -> User Review Screen -> Persistence`.
2. OCR extraction NEVER auto-commits to the SQLite database without explicit user confirmation on the Review Screen.
3. Track confidence metrics (`HIGH`, `MEDIUM`, `LOW`) for fields. Low-confidence fields are highlighted in red/amber on the confirmation UI.
4. Support distinction between `PAID` (Actual Expense) and `DUE` (Obligation / Upcoming Bill).

## Consequences
- 100% financial data accuracy and auditability.
- No phantom transactions created by blurry photos or partial scans.
