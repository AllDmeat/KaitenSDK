# SDK Review & Improvement Plan

Issue #41. Full review of the KaitenSDK codebase.

---

## P1 — API Design

### 1. MockTransport: NSLock → Mutex
`MockClientTransport` is marked `@unchecked Sendable` with `NSLock`. Per rule FR-014 — should use `Mutex` from `Synchronization`.

### 2. Write operations are missing
Present in OpenAPI spec but not implemented in SDK:
- `create_card` — create a card
- `update_card` — update a card
- `delete_card` — delete a card
- `add_comment` — add a comment
- `retrieve_card_comments` — read comments
- `add_member_to_card` — add a member
- `update_member_role` — update member role
- `remove_member_from_card` — remove a member

This is a blocker for MCP write-tools.

### 3. Missing read operations
Present in spec, not implemented:
- `retrieve_space` — get a space by id
- `retrieve_card_comments` — card comments
- `retrieve_card_checklist` — card checklist
- `rertrieve_list_of_tags` — card tags
- `retrieve_list_of_tags` — all tags
- `get_list_of_subcolumns` — subcolumns

### 4. KaitenConfiguration — make public
Currently config is resolved only via env. For flexibility — allow passing config explicitly (internal init already exists, need public).

---

## P2 — Error Handling

### 5. Unify response handling via fromHTTPStatus
`KaitenError.fromHTTPStatus()` is a good helper, but in `KaitenClient` each method manually matches response cases. Can be unified to reduce duplication.

### 6. Add KaitenError.forbidden
403 maps to `unexpectedResponse(statusCode: 403)` in several methods. Should add a separate `.forbidden` case.

---

## P3 — Test Coverage

### 7. RetryMiddleware: test Retry-After parsing
Test verifies that retry occurs, but doesn't verify that the `Retry-After` header is actually parsed.

### 8. Tests for fromHTTPStatus
Utility method without tests.

### 9. Edge case tests
- Empty JSON response
- Invalid JSON
- Empty array (listCards with an empty board)

---

## P4 — Documentation & Ergonomics

### 10. README: code examples
No Swift code snippet with `import KaitenSDK` and a method call.

### 11. DocC documentation target
Public methods have doc-comments, but no DocC catalog.

---

## P5 — Performance

### 12. Exponential backoff in RetryMiddleware
Default 1 second is ok, but should add exponential backoff for sequential retries.

---

## Summary

| # | Priority | Proposal | Effort |
|---|----------|----------|--------|
| 1 | P1 | NSLock → Mutex | S |
| 2 | P1 | Write operations (CRUD cards, comments, members) | L |
| 3 | P1 | Missing read operations | M |
| 4 | P1 | Public config init | S |
| 5 | P2 | Unify error handling via fromHTTPStatus | M |
| 6 | P2 | Add KaitenError.forbidden | S |
| 7 | P3 | Test retry with Retry-After | S |
| 8 | P3 | Tests for fromHTTPStatus | S |
| 9 | P3 | Edge case tests | M |
| 10 | P4 | README code examples | S |
| 11 | P4 | DocC target | M |
| 12 | P5 | Exponential backoff | S |

Awaiting approval — approved items will be filed as separate issues/tasks.
