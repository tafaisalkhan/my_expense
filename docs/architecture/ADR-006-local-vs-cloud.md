# ADR-006: Local Data Isolation vs. Cloud Synchronization Architecture

## Context
Financial records, receipt images, family profile names, and spending details are sensitive user data.

## Decision
1. All database storage, receipt image files, and configuration data remain exclusively on the user's physical device by default.
2. No data, analytics, or receipt scans are sent to external servers without explicit user setup and opt-in consent.
3. Clean Architecture interfaces (`IExpenseRepository`, `IPersonRepository`, `IDocumentScannerService`) decouple storage logic from presentation, enabling future REST API / Firebase sync plugins without refactoring domain or UI logic.

## Consequences
- Privacy by design.
- Zero server infrastructure costs for core functionality.
- Seamless compatibility with cloud backend integration in future releases.
