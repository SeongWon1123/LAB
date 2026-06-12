# Game Balance

## Hourly Drift

- Hunger: `-6`
- Cleanliness: `-4`
- Happiness: `-3`
- Energy while awake: `-5`
- Energy while sleeping: `+12`

## Limits

- Offline simulation cap: 48 hours.
- No death in MVP.
- Low hunger for 8 hours reduces health.
- Low cleanliness for 6 hours makes the pet sick.

## Growth

- Egg to Baby: hatch.
- Baby to Child: 12 hours.
- Child to Teen: 48 hours.
- Teen to Adult: 96 hours.
- Adult to Special: care pattern driven, after MVP hardening.

## Care Actions

- Meal: improves hunger and health.
- Snack: improves hunger and happiness, slightly lowers discipline.
- Clean: improves cleanliness and health.
- Play: improves happiness and mini-game wins, lowers energy.
- Sleep: starts recovery.
- Wake: returns to active care.

## Jump Star Mini-Game

- Target score: 3 stars.
- Jump limit: 8 jumps.
- Timer: 20 seconds.
- Win reward: `happiness +20`, `discipline +2`, `energy -8`, and `totalMiniGameWins +1`.
- Loss reward: `happiness +8`, `discipline +2`, and `energy -8`.
