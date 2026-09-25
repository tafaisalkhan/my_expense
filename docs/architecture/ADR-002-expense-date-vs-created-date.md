# ADR-002: Expense Date vs. Created Date Separation

## Context
Users frequently enter expenses days after the financial transaction actually occurred. Conflating transaction date with entry date distorts analytics, budgets, and historical trends.

## Decision
Every expense entity explicitly distinguishes:
1. `expenseDate` (ISO string `YYYY-MM-DD` or timestamp): The date the money was spent.
2. `expenseTime` (Optional `HH:mm` format): The time of purchase.
3. `createdAt` (ISO 8601 string): The exact timestamp when the record was created in the database.
4. `updatedAt` (ISO 8601 string): The timestamp of the last modification.

Analytics, reports, period comparisons, budget tracking, and forecasts **MUST** query and aggregate strictly by `expenseDate`. `createdAt` is used solely for audit logs and system synchronization.

## Consequences
- Accurate financial reports regardless of when entry occurred.
- Historical expense insertion (backdating) seamlessly updates historical graphs and totals.
