# KaitenSDK Constitution

## Core Principles

### I. OpenAPI-First

OpenAPI-спека — единственный источник правды для API-контракта. Клиентский код генерируется из неё через `swift-openapi-generator`. Ручной код HTTP-запросов запрещён.

### II. Cross-Platform

Код компилируется и работает на macOS, Linux и Windows. Никаких `#if os(...)` для бизнес-логики. Platform-specific код допустим только в транспортном слое.

### III. Generated Over Handwritten

Предпочитаем генерацию кода ручному написанию. Если что-то можно сгенерировать из спеки — генерируем. Обёртки поверх сгенерированного кода — минимальные, для удобства API.

### IV. Configuration as Code

URL и другие настройки — через `swift-configuration` (environment variables, конфиг-файлы). Токены — через secrets provider. Никаких захардкоженных значений.

### V. Simplicity

YAGNI. Реализуем только то, что нужно прямо сейчас. Новые эндпоинты добавляются в OpenAPI-спеку → клиент перегенерируется автоматически.

## Technology Stack

- **Swift 6.2**, Swift Package Manager
- **`apple/swift-openapi-generator`** + `swift-openapi-runtime` — генерация клиента
- **`apple/swift-configuration`** — конфигурация
- **Swift Testing** — тесты
- **GitHub Actions** — CI, матрица macOS/Linux/Windows

## Quality Gates

- CI проходит на всех трёх платформах
- OpenAPI-спека валидна
- Сгенерированный код компилируется без ошибок
- Тесты проходят

## Governance

Конституция имеет приоритет над всеми другими практиками. Изменения требуют документации и обоснования.

**Version**: 1.0.0 | **Ratified**: 2026-02-14 | **Last Amended**: 2026-02-14
