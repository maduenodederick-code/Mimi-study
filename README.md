# Mimi Study

Mimi Study is an AI smart learning assistant built with Flutter.

## Current foundation

- Soft blush pink and warm cream visual theme
- Five-tab navigation: Home, Plan, AI Assistant, Library, and Profile
- Home dashboard with live task counts and quick actions
- Add and complete study tasks
- Study plan progress overview
- Pomodoro timer with 25-minute focus, 5-minute short break, and 15-minute long break presets
- Starter widget tests for the home screen, navigation, and timer

## Run locally

Install Flutter, then run:

```bash
flutter pub get
flutter test
flutter run
```

## Development branch

The current implementation is on `feature/mimi-study-foundation`.
The original `main` branch is preserved. A backup branch named
`backup/before-app-scaffold` was created before changes.

## Current limitations

Tasks and timer state are currently held in memory. They reset when the app is restarted.
The AI assistant, knowledge library, profile, notes, and persistent study history are not implemented yet.
