import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_memory_pet/features/pet/application/care_actions.dart';
import 'package:pocket_memory_pet/features/pet/domain/care_event.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';

void main() {
  group('CareActionService', () {
    const service = CareActionService();
    final now = DateTime.parse('2026-06-12T00:00:00Z');

    test('feedMeal improves hunger and records event', () {
      final session = PetSession.initial(now);
      final result = service.feedMeal(session, now);

      expect(result.pet.hunger, greaterThan(session.pet.hunger));
      expect(result.pet.totalMeals, 1);
      expect(result.careEvents.first, isA<CareEvent>());
      expect(result.diary.first.title, 'A warm meal');
    });

    test('feedSnack improves happiness and lowers discipline', () {
      final session = PetSession.initial(now);
      final result = service.feedSnack(session, now);

      expect(result.pet.happiness, greaterThan(session.pet.happiness));
      expect(result.pet.discipline, lessThan(session.pet.discipline));
      expect(result.pet.totalSnacks, 1);
    });

    test('cleanRoom clears sick state', () {
      final base = PetSession.initial(now);
      final session = base.copyWith(
        pet: base.pet.copyWith(isSick: true, cleanliness: 10),
      );
      final result = service.cleanRoom(session, now);

      expect(result.pet.isSick, isFalse);
      expect(result.pet.cleanliness, greaterThan(10));
    });

    test('sleep and wake toggle sleeping state', () {
      final sleeping = service.startSleep(PetSession.initial(now), now);
      final awake = service.wakeUp(sleeping, now);

      expect(sleeping.pet.isSleeping, isTrue);
      expect(awake.pet.isSleeping, isFalse);
    });

    test('mini game win increments win count', () {
      final result = service.playMiniGameResult(PetSession.initial(now), now, won: true);

      expect(result.pet.totalMiniGameWins, 1);
      expect(result.pet.energy, lessThan(74));
    });
  });
}
