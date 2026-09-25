# ADR-003: Family / Person Entity Model

## Context
Expenses can belong to household totals or be attributed to specific family members (e.g. Son's school fees, Daughter's medicines). Representing people as subcategories causes category hierarchy breakdown and destroys analytical integrity.

## Decision
`Person` is modeled as a first-class domain entity with its own database table (`people`).
An `Expense` entity has an optional `personId` foreign key field:
- `personId == null`: General household expense (e.g., house rent, general groceries, electricity).
- `personId != null`: Dedicated expense for that individual.

## Consequences
- Clean separation between Category taxonomy (Education -> Exam Fee) and Person attribution (Son -> Ahmed).
- Capability to slice analytics either by Category or by Person independently.
