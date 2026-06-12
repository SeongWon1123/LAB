# Architecture

## Shape

Feature-first Flutter app with small domain objects, repository interfaces, local Hive CE adapters through primitive JSON maps, and Riverpod controllers.

## Layers

- `domain`: immutable models, enums, repository contracts.
- `data`: Hive and in-memory repository implementations.
- `application`: elapsed-time simulation, care actions, Riverpod controller.
- `presentation`: Flutter screens and widgets.
- `core`: routing, theme, notifications, storage, and audio services.
- `shared`: reusable pixel, layout, and button widgets.

## Persistence

Hive CE stores a serialized `PetSession` map. Domain models expose `toJson` and `fromJson` so storage can be replaced later without UI changes.

## Time

All model timestamps are UTC. On load or app resume, the app calculates elapsed hours from `lastUpdatedAtUtc`, caps simulation at 48 hours, applies balance rules, and saves the updated state.

## Future Backup

Repository interfaces are stable boundaries. A later cloud repository can implement the same contracts without changing presentation widgets.
