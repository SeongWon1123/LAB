import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_memory_pet/features/pet/application/elapsed_time_simulator.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_enums.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';

void main() {
  group('ElapsedTimeSimulator', () {
    const simulator = ElapsedTimeSimulator();
    final baseTime = DateTime.parse('2026-06-12T00:00:00Z');

    PetSession session({
      int ageHours = 0,
      bool sleeping = false,
      int hunger = 80,
      int clean = 80,
    }) {
      final initial = PetSession.initial(baseTime);
      return initial.copyWith(
        pet: initial.pet.copyWith(
          name: 'Cloudy',
          stage: EvolutionStage.baby,
          ageHours: ageHours,
          hunger: hunger,
          cleanliness: clean,
          isSleeping: sleeping,
          lastUpdatedAtUtc: baseTime,
        ),
      );
    }

    test('does not apply changes below one hour', () {
      final result = simulator.apply(session(), baseTime.add(const Duration(minutes: 30)));
      expect(result.pet.hunger, 80);
    });

    test('reduces hunger each elapsed hour', () {
      final result = simulator.apply(session(), baseTime.add(const Duration(hours: 2)));
      expect(result.pet.hunger, 68);
    });

    test('reduces cleanliness each elapsed hour', () {
      final result = simulator.apply(session(), baseTime.add(const Duration(hours: 3)));
      expect(result.pet.cleanliness, 68);
    });

    test('reduces happiness each elapsed hour', () {
      final result = simulator.apply(session(), baseTime.add(const Duration(hours: 4)));
      expect(result.pet.happiness, 64);
    });

    test('reduces energy while awake', () {
      final result = simulator.apply(session(), baseTime.add(const Duration(hours: 2)));
      expect(result.pet.energy, 64);
    });

    test('increases energy while sleeping', () {
      final result = simulator.apply(
        session(sleeping: true),
        baseTime.add(const Duration(hours: 2)),
      );
      expect(result.pet.energy, 98);
    });

    test('caps offline elapsed time at 48 hours', () {
      final result = simulator.apply(session(), baseTime.add(const Duration(days: 10)));
      expect(result.pet.ageHours, 48);
    });

    test('applies low hunger health penalty', () {
      final result = simulator.apply(
        session(hunger: 8),
        baseTime.add(const Duration(hours: 8)),
      );
      expect(result.pet.health, 82);
    });

    test('marks pet sick after long low cleanliness', () {
      final result = simulator.apply(
        session(clean: 18),
        baseTime.add(const Duration(hours: 6)),
      );
      expect(result.pet.isSick, isTrue);
    });

    test('evolves to child after 12 hours', () {
      final result = simulator.apply(session(), baseTime.add(const Duration(hours: 12)));
      expect(result.pet.stage, EvolutionStage.child);
    });

    test('creates diary entry when growth stage changes', () {
      final result = simulator.apply(session(), baseTime.add(const Duration(hours: 12)));
      expect(result.diary.first.type, DiaryEntryType.growth);
    });
  });
}
