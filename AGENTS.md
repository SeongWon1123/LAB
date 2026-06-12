# AGENTS.md

## Project

Build Pocket Memory Pet, an original Flutter mobile app for iOS and Android. The MVP is a serverless, local-first retro pixel pet experience with warm desk nostalgia, a soft LCD screen, and three-button care.

## Fixed Stack

- Flutter and Dart
- Riverpod for state management
- Hive CE for all MVP local persistence
- go_router for routing
- flutter_local_notifications for local reminders
- Flame for future lightweight mini-game work
- flutter_test, mocktail, and golden_toolkit for tests

## IP Safety

- Do not copy any existing toy or game brand's product shape, logo, character, icon layout, sounds, screen composition, photos, packaging, or manual text.
- Do not use third-party brand names from the master plan in app names, package names, code identifiers, store metadata, screenshot copy, tags, or marketing copy.
- Use only general retro digital pet inspiration and original visual/audio assets.
- Keep legal disclaimer text in README, store drafts, and privacy docs.

## MVP Includes

Onboarding, pet naming, hatch, home, status, feed, snack, play, clean, sleep/wake, elapsed-time calculation, growth stages, diary entries, Hive CE local storage, local notification permission flow, settings, Android/iOS build-ready structure.

## MVP Excludes

No Firebase, server, login, cloud backup, ads, purchases, friends, chat, ranking, AR, home widget, random draws, UGC, or community features.

## Implementation Rules

- Store all DateTime values in UTC.
- Recalculate pet state from `lastUpdatedAtUtc` whenever the app resumes or loads.
- Cap offline elapsed simulation to 48 hours.
- Do not implement pet death in the MVP.
- Notification denial must not block app usage.
- Do not depend on Android exact alarm permissions.
- Use repository interfaces so Phase 2 backup can replace Hive without touching UI logic.

## Verification

Run these after changes when Flutter is available:

```bash
flutter analyze
flutter test
```

For release readiness:

```bash
flutter build apk --debug
flutter build appbundle --release
```

## Commit Style

Use concise commits that describe the product area, for example `Add pet state model` or `Implement retro home shell`.
