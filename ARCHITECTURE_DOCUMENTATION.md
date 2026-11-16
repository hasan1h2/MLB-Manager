# MLB Manager — Architecture Documentation

## Architectural Paradigm
MLB Manager is architected using a **Clean Modular Feature-First Architecture** combined with **GetX** for dependency injection and state management, and **Drift / SQLite** for relational data persistence.

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                     │
│    (Views, Responsive Layouts, Widgets, GetView/GetWidget)   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    Controller Layer (Getx)                  │
│  (State Orchestration, UI Events, Form Validations, Obx)   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                        Domain Layer                         │
│  (Use Cases, Business Rules, Financial Engine, Entities)    │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                         Data Layer                          │
│  (Repository Implementations, Drift DAOs, Drift Tables)     │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    Persistence / Engine                     │
│    (SQLite, sqlite3_flutter_libs, FlutterSecureStorage)     │
└─────────────────────────────────────────────────────────────┘
```

---

## Directory & Package Conventions
- `lib/main.dart`: Application entry point, initializing core engines and initial binding.
- `lib/app/`: Top-level app widget (`app.dart`), route definitions (`app_routes.dart`), and route pages (`app_pages.dart`).
- `lib/core/`:
  - `constants/`: `app_constants.dart`, `app_strings.dart`, `app_colors.dart`, `app_icons.dart`, `app_sizes.dart`.
  - `theme/`: Light and dark Material 3 themes (`app_theme.dart`).
  - `localization/`: Multi-language translations (`app_translations.dart`, `bn_bd.dart`, `en_us.dart`).
  - `database/`: Drift database class (`app_database.dart`), tables (`tables/`), DAOs (`daos/`).
  - `services/`: Global persistent services (Auth/PIN, Storage, Localization, Notification, Audio/OCR).
  - `utils/`: Exact currency math, formatting, date utilities, validators.
- `lib/features/`: Isolated business feature slices:
  - `dashboard`
  - `authentication`
  - `family`
  - `personal_finance`
  - `household`
  - `transactions`
  - `business`
  - `cattle`
  - `inventory`
  - `customers`
  - `suppliers`
  - `loans`
  - `accounts`
  - `assets`
  - `budgets`
  - `reports`
  - `ai_assistant`
  - `reminders`
  - `documents`
  - `backup`
  - `settings`
- `lib/shared/`: Cross-cutting widgets (custom buttons, cards, currency inputs, dialogs, charts) and enums.

---

## Dependency Injection via GetX Bindings
Each feature module provides a `Bindings` class (e.g., `DashboardBinding`, `TransactionBinding`) loaded lazily or immediately upon routing:
```dart
class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionRepository>(() => TransactionRepositoryImpl(Get.find()));
    Get.lazyPut(() => CreateTransactionUseCase(Get.find()));
    Get.lazyPut(() => TransactionController(Get.find(), Get.find()));
  }
}
```
This guarantees separation of concerns, testability through mocking, and optimal memory lifecycle management.
