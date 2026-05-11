# HUDYAT Tracker

A Flutter-based membership and duty management app for the HUDYAT organization, with role-based dashboards for Admins, Officers, and Members.

## Features

- **Role-based access** — separate dashboards for Admin, Officer, and Member roles
- **Duty management** — assign, log, and track member duties
- **Event management** — create and manage organizational events with a calendar view
- **Analytics & reports** — performance metrics and member classification charts
- **Token-based authentication** — secure login with session persistence

## Tech Stack

- **Flutter** with Provider for state management
- **Plain PHP REST API** backend (HUDYAT API)
- [`fl_chart`](https://pub.dev/packages/fl_chart) for analytics charts
- [`table_calendar`](https://pub.dev/packages/table_calendar) for calendar scheduling
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) for local token storage

## Getting Started

### Prerequisites

- Flutter SDK installed ([install guide](https://docs.flutter.dev/get-started/install))
- A running instance of the HUDYAT PHP backend

### Running the App

```bash
flutter pub get
flutter run
If testing on a physical device, update the base API URL in the service files to match your machine's local IP address.

Project Structure

lib/
├── main.dart
├── providers/        # Event, Duty state management
├── screens/
│   ├── auth/         # Login screen
│   ├── admin/        # Admin dashboard and tabs
│   ├── officer/      # Officer dashboard and tabs
│   └── member/       # Member dashboard and tabs
└── services/         # API communication layer


The only thing to double-check before pasting — if you do have an `auth_provider.dart` file in your providers folder, add `Auth,` back to the providers comment line.
