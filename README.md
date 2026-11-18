# Mimi Study

Mimi Study is a Flutter-based study companion with a soft blush-pink and warm-cream interface.

## Features

- Five-tab navigation: Home, Plan, AI Assistant, Knowledge Base, and Profile
- Home dashboard with task counts, quick actions, and accumulated focus time
- Create and complete study tasks, with a study-plan progress overview
- Pomodoro timer with 25-minute focus, 5-minute short break, and 15-minute long break presets
- Local persistence for study tasks, knowledge-base notes, accumulated focus minutes, and daily focus sessions
- Knowledge base with note creation, editing, deletion, and keyword search
- Profile dashboard with task totals, completion rate, focus time, note count, and a seven-day focus history
- Profile settings describing the current theme and on-device data storage
- Confirmed option to clear all locally stored study data
- AI assistant chat preview (a live AI service is not connected yet)

## Run locally

Install Flutter, then run:

```bash
flutter pub get
flutter test
flutter run
```

## Automated tests

GitHub Actions runs `flutter test` on pushes to `main` and `feature/mimi-study-foundation`, pull requests targeting `main`, and manual workflow dispatches.

## Development branch

The current implementation is on `feature/mimi-study-foundation`.
The original `main` branch is preserved. A backup branch named
`backup/before-app-scaffold` was created before changes.

## Current limitations

- Study data is stored locally on the current device; cloud sync and account login are not implemented.
- The AI assistant is a UI preview and does not yet connect to a model service.
- Daily focus history records completed 25-minute focus sessions by local calendar day. Existing cumulative totals are retained, while daily breakdowns begin from the feature's installation.
- Theme selection is currently informational; the app uses its existing pink-and-cream theme.
