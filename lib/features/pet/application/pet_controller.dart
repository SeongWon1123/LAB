import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_memory_pet/features/pet/application/care_actions.dart';
import 'package:pocket_memory_pet/features/pet/application/elapsed_time_simulator.dart';
import 'package:pocket_memory_pet/features/pet/data/in_memory_pet_repository.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_repository.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';

final petRepositoryProvider = Provider<PetRepository>(
  (ref) => InMemoryPetRepository(),
);

final initialPetSessionProvider = Provider<PetSession>(
  (ref) => PetSession.initial(DateTime.now().toUtc()),
);

final petControllerProvider = NotifierProvider<PetController, PetSession>(
  PetController.new,
);

class PetController extends Notifier<PetSession> {
  final CareActionService _care = const CareActionService();
  final ElapsedTimeSimulator _simulator = const ElapsedTimeSimulator();

  @override
  PetSession build() {
    return ref.watch(initialPetSessionProvider);
  }

  void refreshElapsed([DateTime? nowUtc]) {
    _commit(_simulator.apply(state, nowUtc ?? DateTime.now().toUtc()));
  }

  void namePet(String name) {
    if (name.trim().isEmpty) {
      return;
    }
    _commit(_care.namePet(state, name, DateTime.now().toUtc()));
  }

  void hatch() {
    _commit(_care.hatch(state, DateTime.now().toUtc()));
  }

  void feedMeal() {
    _commit(_care.feedMeal(state, DateTime.now().toUtc()));
  }

  void feedSnack() {
    _commit(_care.feedSnack(state, DateTime.now().toUtc()));
  }

  void cleanRoom() {
    _commit(_care.cleanRoom(state, DateTime.now().toUtc()));
  }

  void toggleSleep() {
    final next = state.pet.isSleeping
        ? _care.wakeUp(state, DateTime.now().toUtc())
        : _care.startSleep(state, DateTime.now().toUtc());
    _commit(next);
  }

  void play({bool won = true}) {
    _commit(_care.playMiniGameResult(state, DateTime.now().toUtc(), won: won));
  }

  void setNotificationsEnabled({required bool enabled}) {
    _commit(state.copyWith(notificationsEnabled: enabled));
  }

  void setSoundEnabled({required bool enabled}) {
    _commit(state.copyWith(soundEnabled: enabled));
  }

  Future<void> reset() async {
    final repository = ref.read(petRepositoryProvider);
    final resetSession = await repository.resetSession(DateTime.now().toUtc());
    state = resetSession;
  }

  void _commit(PetSession next) {
    state = next;
    unawaited(ref.read(petRepositoryProvider).saveSession(next));
  }
}
