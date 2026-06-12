import 'package:pocket_memory_pet/features/pet/domain/care_event.dart';
import 'package:pocket_memory_pet/features/pet/domain/diary_entry.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_enums.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_state.dart';

class CareActionService {
  const CareActionService();

  PetSession namePet(PetSession session, String name, DateTime nowUtc) {
    final now = nowUtc.toUtc();
    return session.copyWith(
      pet: session.pet.copyWith(name: name.trim(), lastUpdatedAtUtc: now, lastOpenedAtUtc: now),
      diary: [
        DiaryEntry(
          id: 'name-${now.microsecondsSinceEpoch}',
          createdAtUtc: now,
          type: DiaryEntryType.system,
          title: 'A name was whispered',
          body: '${name.trim()} is ready to wake up inside the little screen.',
          iconId: 'name',
        ),
        ...session.diary,
      ],
    );
  }

  PetSession hatch(PetSession session, DateTime nowUtc) {
    final now = nowUtc.toUtc();
    return session.copyWith(
      pet: session.pet.copyWith(stage: EvolutionStage.baby, lastUpdatedAtUtc: now),
      diary: [
        DiaryEntry(
          id: 'hatch-${now.microsecondsSinceEpoch}',
          createdAtUtc: now,
          type: DiaryEntryType.hatch,
          title: 'The shell blinked open',
          body: '${_name(session)} met the world for the first time.',
          iconId: 'egg',
        ),
        ...session.diary,
      ],
    );
  }

  PetSession feedMeal(PetSession session, DateTime nowUtc) {
    return _apply(
      session,
      nowUtc,
      CareAction.feedMeal,
      const {'hunger': 30, 'health': 4},
      title: 'A warm meal',
      body: '${_name(session)} ate slowly and looked brighter.',
      petBuilder: (pet) => pet.copyWith(
        hunger: pet.hunger + 30,
        health: pet.health + 4,
        totalMeals: pet.totalMeals + 1,
      ),
    );
  }

  PetSession feedSnack(PetSession session, DateTime nowUtc) {
    return _apply(
      session,
      nowUtc,
      CareAction.feedSnack,
      const {'hunger': 12, 'happiness': 18, 'discipline': -4},
      title: 'A tiny snack',
      body: '${_name(session)} made a happy little face.',
      petBuilder: (pet) => pet.copyWith(
        hunger: pet.hunger + 12,
        happiness: pet.happiness + 18,
        discipline: pet.discipline - 4,
        totalSnacks: pet.totalSnacks + 1,
      ),
    );
  }

  PetSession cleanRoom(PetSession session, DateTime nowUtc) {
    return _apply(
      session,
      nowUtc,
      CareAction.cleanRoom,
      const {'cleanliness': 35, 'health': 5},
      title: 'A tidy room',
      body: 'The LCD room feels soft and clean again.',
      petBuilder: (pet) => pet.copyWith(
        cleanliness: pet.cleanliness + 35,
        health: pet.health + 5,
        totalCleanups: pet.totalCleanups + 1,
        isSick: false,
      ),
    );
  }

  PetSession startSleep(PetSession session, DateTime nowUtc) {
    return _apply(
      session,
      nowUtc,
      CareAction.startSleep,
      const {'discipline': 3},
      title: 'Lights out',
      body: '${_name(session)} curled up under pixel stars.',
      petBuilder: (pet) => pet.copyWith(isSleeping: true, discipline: pet.discipline + 3),
    );
  }

  PetSession wakeUp(PetSession session, DateTime nowUtc) {
    return _apply(
      session,
      nowUtc,
      CareAction.wakeUp,
      const {'happiness': 4},
      title: 'Good morning',
      body: '${_name(session)} blinked awake on the LCD screen.',
      petBuilder: (pet) => pet.copyWith(isSleeping: false, happiness: pet.happiness + 4),
    );
  }

  PetSession playMiniGameResult(PetSession session, DateTime nowUtc, {required bool won}) {
    return _apply(
      session,
      nowUtc,
      CareAction.playMiniGameResult,
      {'happiness': won ? 20 : 8, 'energy': -8, 'discipline': 2},
      title: won ? 'A star was caught' : 'A soft little try',
      body: won
          ? '${_name(session)} caught a blinking star.'
          : '${_name(session)} tried again and still had fun.',
      petBuilder: (pet) => pet.copyWith(
        happiness: pet.happiness + (won ? 20 : 8),
        energy: pet.energy - 8,
        discipline: pet.discipline + 2,
        totalMiniGameWins: pet.totalMiniGameWins + (won ? 1 : 0),
      ),
    );
  }

  PetSession _apply(
    PetSession session,
    DateTime nowUtc,
    CareAction action,
    Map<String, int> delta, {
    required String title,
    required String body,
    required PetState Function(PetState pet) petBuilder,
  }) {
    final now = nowUtc.toUtc();
    final pet = petBuilder(session.pet).copyWith(lastUpdatedAtUtc: now, lastOpenedAtUtc: now);

    return session.copyWith(
      pet: pet,
      careEvents: [
        CareEvent(
          id: '${action.name}-${now.microsecondsSinceEpoch}',
          createdAtUtc: now,
          action: action,
          valueDelta: delta,
        ),
        ...session.careEvents,
      ],
      diary: [
        DiaryEntry(
          id: 'diary-${action.name}-${now.microsecondsSinceEpoch}',
          createdAtUtc: now,
          type: DiaryEntryType.care,
          title: title,
          body: body,
          iconId: action.name,
        ),
        ...session.diary,
      ],
    );
  }

  String _name(PetSession session) {
    final name = session.pet.name.trim();
    return name.isEmpty ? 'Your tiny friend' : name;
  }
}
