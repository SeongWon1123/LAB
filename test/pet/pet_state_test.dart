import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_enums.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_state.dart';

void main() {
  group('PetState', () {
    test('creates an egg pet with UTC timestamps', () {
      final now = DateTime.parse('2026-06-12T00:00:00Z');
      final pet = PetState.initial(now);

      expect(pet.stage, EvolutionStage.egg);
      expect(pet.bornAtUtc.isUtc, isTrue);
      expect(pet.lastUpdatedAtUtc.isUtc, isTrue);
    });

    test('copyWith clamps stat values to 0..100', () {
      final pet = PetState.initial(DateTime.parse('2026-06-12T00:00:00Z'))
          .copyWith(hunger: 200, happiness: -10);

      expect(pet.hunger, 100);
      expect(pet.happiness, 0);
    });

    test('serializes and restores core fields', () {
      final pet = PetState.initial(DateTime.parse('2026-06-12T00:00:00Z')).copyWith(
        name: 'Cloudy',
        stage: EvolutionStage.child,
        ageHours: 12,
      );

      final restored = PetState.fromJson(pet.toJson());

      expect(restored.name, 'Cloudy');
      expect(restored.stage, EvolutionStage.child);
      expect(restored.ageHours, 12);
    });
  });
}
