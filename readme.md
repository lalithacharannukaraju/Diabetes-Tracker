# Diabetes Tracker Flutter App

This repository contains the frontend for a diabetes tracking application built with Flutter. It includes:

- A login screen
- Medicine management (add on a dedicated page, view scheduled/to‑do list)

Each medicine can be given a time and selected weekdays; the "Medicine" tab automatically shows items due for the current day or the day selected in the calendar.
- Diet logging per day
- Calendar view to track previous entries

### Dependencies

The frontend uses the following Flutter packages:

- `provider` for state management
- `table_calendar` for calendar UI
- `cupertino_icons` for iconography


## Getting Started

1. Ensure you have the [Flutter SDK](https://flutter.dev) installed and added to your `PATH`.
2. Run the following commands in the project root:
   ```bash
   flutter pub get
   flutter run
   ```
3. The app will start on your connected device or emulator.

> ⚠️ **Note:** Flutter is not installed in the current environment, so the scaffolding here was created manually. Execute the above commands on your local machine with Flutter set up.

The `lib/` directory holds the source code, with screens organized under `lib/screens` and models under `lib/models`.

