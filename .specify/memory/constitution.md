# KaitenSDK Constitution

## Core Principles

### I. OpenAPI-First

The OpenAPI spec is the single source of truth for the API contract.
Client code is generated from it. Hand-written HTTP request code
is prohibited.

### II. Generated Over Handwritten

Prefer code generation over hand-writing. If something can be
generated from the spec — generate it. Wrappers over generated
code MUST be minimal and serve solely for API convenience.

### III. Configuration as Code

Settings — via config files or arguments.
Hard-coded values are prohibited.

### IV. Simplicity

YAGNI. Implement only what is needed right now.
New endpoints are added to the OpenAPI spec → the client
is regenerated automatically. Premature abstractions are prohibited.

## Quality Gates

- CI MUST pass
- OpenAPI spec MUST be valid
- Generated code MUST compile without errors
- Tests MUST pass

## Governance

The constitution takes priority over all other project practices.

### Amendment Procedure

1. A change proposal is submitted with justification.
2. The change is documented in this file.
3. The version is updated following semantic versioning rules.

### Versioning Policy

- **MAJOR**: backward-incompatible changes to principles (removal,
  redefinition).
- **MINOR**: addition of a new principle or significant expansion
  of an existing section.
- **PATCH**: wording clarifications, typo fixes,
  non-semantic edits.

### Compliance Review

- Every PR MUST be reviewed for compliance with constitution principles.
- Violations are acceptable only with explicit justification in the
  Complexity Tracking section of the plan.

**Version**: 2.0.0 | **Ratified**: 2026-02-14 | **Last Amended**: 2026-02-16
