# ADR-004: Recurring Expense Generation & Idempotency

## Context
Automated or semi-automated recurring expenses (e.g. monthly rent, school fee) run risk of generating duplicate expense items if background jobs or user trigger events run multiple times on the same date.

## Decision
1. Recurring rules store schedule parameters (`frequency`, `interval`, `dayOfMonth`, `nextOccurrence`).
2. Occurrences are logged in `recurring_occurrences` table with a composite `UNIQUE(recurringRuleId, scheduledDate)` index.
3. Attempting to approve or generate a recurring expense for a target date first checks if a matching record exists in `recurring_occurrences`.

## Consequences
- Guaranteed idempotency; recurring tasks will never double-charge or create duplicate transactions.
- Audit trail for skipped, pending, and approved recurring bills.
