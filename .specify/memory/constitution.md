<!--
Sync Impact Report
===================
Version change: 1.0.0 → 1.1.0
Bump rationale: MINOR — expanded Governance section with amendment
procedure, versioning policy, and compliance review expectations.

Modified principles: none (titles and content unchanged)
Added sections: none (Governance expanded in-place)
Removed sections: none

Templates requiring updates:
  - .specify/templates/plan-template.md — ✅ no update needed
    (Constitution Check section references constitution generically)
  - .specify/templates/spec-template.md — ✅ no update needed
    (no direct constitution references)
  - .specify/templates/tasks-template.md — ✅ no update needed
    (no direct constitution references)
  - .specify/templates/checklist-template.md — ✅ no update needed
  - .specify/templates/agent-file-template.md — ✅ no update needed
  - No command files exist in .specify/templates/commands/

Follow-up TODOs: none
-->

# KaitenSDK Constitution

## Core Principles

### I. OpenAPI-First

OpenAPI-спека — единственный источник правды для API-контракта.
Клиентский код генерируется из неё через `swift-openapi-generator`.
Ручной код HTTP-запросов запрещён.

### II. Cross-Platform

Код MUST компилироваться и работать на macOS, Linux и Windows.
Никаких `#if os(...)` для бизнес-логики.
Platform-specific код допустим только в транспортном слое.

### III. Generated Over Handwritten

Предпочитаем генерацию кода ручному написанию. Если что-то можно
сгенерировать из спеки — генерируем. Обёртки поверх сгенерированного
кода MUST быть минимальными и служить исключительно удобству API.

### IV. Configuration as Code

URL и другие настройки — через `swift-configuration`
(environment variables, конфиг-файлы). Токены — через secrets
provider. Захардкоженные значения запрещены.

### V. Simplicity

YAGNI. Реализуем только то, что нужно прямо сейчас.
Новые эндпоинты добавляются в OpenAPI-спеку → клиент
перегенерируется автоматически. Преждевременные абстракции запрещены.

## Technology Stack

- **Swift 6.2**, Swift Package Manager
- **`apple/swift-openapi-generator`** + `swift-openapi-runtime` — генерация клиента
- **`apple/swift-configuration`** — конфигурация
- **Swift Testing** — тесты
- **GitHub Actions** — CI, матрица macOS/Linux/Windows

## Quality Gates

- CI MUST проходить на всех трёх платформах
- OpenAPI-спека MUST быть валидна
- Сгенерированный код MUST компилироваться без ошибок
- Тесты MUST проходить

## Governance

Конституция имеет приоритет над всеми другими практиками проекта.

### Amendment Procedure

1. Предложение изменения оформляется с обоснованием.
2. Изменение документируется в этом файле.
3. Версия обновляется по правилам семантического версионирования.

### Versioning Policy

- **MAJOR**: обратно несовместимые изменения принципов (удаление,
  переопределение).
- **MINOR**: добавление нового принципа или существенное расширение
  существующего раздела.
- **PATCH**: уточнения формулировок, исправление опечаток,
  несемантические правки.

### Compliance Review

- Каждый PR MUST проверяться на соответствие принципам конституции.
- Нарушения допустимы только с явным обоснованием в Complexity
  Tracking секции плана.

**Version**: 1.1.0 | **Ratified**: 2026-02-14 | **Last Amended**: 2026-02-16
