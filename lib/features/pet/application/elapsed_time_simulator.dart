import 'dart:math';

import 'package:pocket_memory_pet/features/pet/application/pet_balance.dart';
import 'package:pocket_memory_pet/features/pet/domain/diary_entry.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_enums.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_state.dart';

class ElapsedTimeSimulator {
  const ElapsedTimeSimulator({this.balance = const PetBalance()});

  final PetBalance balance;

  PetSession apply(PetSession session, DateTime nowUtc) {
    final now = nowUtc.toUtc();
    final elapsed = now.difference(session.pet.lastUpdatedAtUtc);

    if (elapsed.isNegative || elapsed.inMinutes < 60) {
      return session.copyWith(
        pet: session.pet.copyWith(lastOpenedAtUtc: now),
      );
    }

    final elapsedHours = min(balance.maxOfflineHours, elapsed.inHours);
    final pet = session.pet;
    final nextAge = pet.ageHours + elapsedHours;
    final nextStage = _stageForAge(current: pet.stage, ageHours: nextAge);
    final lowHungerPenalty =
        pet.hunger <= 10 && elapsedHours >= balance.lowHungerPenaltyHours;
    final sickFromMess =
        pet.cleanliness <= 20 && elapsedHours >= balance.lowCleanlinessSickHours;

    final updatedPet = pet.copyWith(
      hunger: pet.hunger - balance.hungerLossPerHour * elapsedHours,
      cleanliness: pet.cleanliness - balance.cleanlinessLossPerHour * elapsedHours,
      happiness: pet.happiness - balance.happinessLossPerHour * elapsedHours,
      energy: pet.isSleeping
          ? pet.energy + balance.sleepEnergyGainPerHour * elapsedHours
          : pet.energy - balance.awakeEnergyLossPerHour * elapsedHours,
      health: lowHungerPenalty ? pet.health - balance.lowHungerHealthPenalty : pet.health,
      ageHours: nextAge,
      careMistakes: pet.careMistakes + (lowHungerPenalty || sickFromMess ? 1 : 0),
      stage: nextStage,
      isSick: pet.isSick || sickFromMess,
      lastUpdatedAtUtc: now,
      lastOpenedAtUtc: now,
    );

    final diary = [...session.diary];
    if (nextStage != pet.stage) {
      diary.insert(
        0,
        DiaryEntry(
          id: 'growth-${now.microsecondsSinceEpoch}',
          createdAtUtc: now,
          type: DiaryEntryType.growth,
          title: 'A new shape appeared',
          body: '${updatedPet.nameOrFriend} grew into ${nextStage.label}.',
          iconId: 'growth',
        ),
      );
    }

    return session.copyWith(pet: updatedPet, diary: diary);
  }

  EvolutionStage _stageForAge({
    required EvolutionStage current,
    required int ageHours,
  }) {
    if (current == EvolutionStage.special) {
      return current;
    }
    if (current == EvolutionStage.egg) {
      return current;
    }
    if (ageHours >= 96) {
      return EvolutionStage.adult;
    }
    if (ageHours >= 48) {
      return EvolutionStage.teen;
    }
    if (ageHours >= 12) {
      return EvolutionStage.child;
    }
    return EvolutionStage.baby;
  }
}

extension PetNameFallback on PetState {
  String get nameOrFriend {
    if (name.trim().isEmpty) {
      return 'Your tiny friend';
    }
    return name;
  }
}
