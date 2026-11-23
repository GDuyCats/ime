# IME - I Manage Everything

Local-first money manager for rentals and small businesses.
Flutter app for Android and Windows. All data stays in a SQLite file on the device.

## First-time setup (Windows)

Run every command in Command Prompt from the project folder `D:\ime`
(`cd /d D:\ime`).

1. Generate the platform folders (only once):
   `flutter create . --project-name ime --org com.gduycats --platforms=android,windows`
2. Download packages: `flutter pub get`
3. Run the tests: `flutter test`
4. Start the Windows app: `flutter run -d windows`

## Project layout

| Path | What it holds |
| --- | --- |
| `lib/main.dart`, `lib/app.dart` | App entry point, theme, language setup |
| `lib/data/schema.dart` | SQL for every table (version 1) |
| `lib/data/app_database.dart` | Opens the SQLite file (FFI on Windows, plugin on Android) |
| `lib/data/models.dart` | Book, Item and enums |
| `lib/data/*_repository.dart` | Read and write rows |
| `lib/ui/` | Screens and shared widgets |
| `lib/l10n/*.arb` | All user-facing text (`app_vi.arb` = Vietnamese) |
| `lib/utils/` | Money and number helpers, ids |
| `test/` | Unit tests |

## Conventions

- Ids are UUID strings; rows have `created_at`, `updated_at`, `deleted_at`
  (epoch milliseconds) and are only soft-deleted.
- Money is stored as integers in the currency's minor unit (VND: dong, USD: cents).
- User-facing text lives in the ARB files, never in Dart code.

## License

Source available for viewing. All rights reserved.
No permission is granted to copy, modify, or distribute this code.
