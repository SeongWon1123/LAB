# Data Model

## PetState

Tracks identity, growth stage, six care stats, age, care counters, UTC lifecycle timestamps, skin/room IDs, and sleep/sick flags.

## InventoryItem

Tracks unlocked local items and quantities. MVP starts with structure only.

## DiaryEntry

Records meaningful care, growth, hatch, and system events.

## CareEvent

Records each care action with UTC time and stat deltas.

## Value Rules

- Stat values are clamped to `0..100`.
- All timestamps are converted to UTC before save.
- MVP does not create death states.
