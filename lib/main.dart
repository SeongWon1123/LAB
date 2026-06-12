import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_memory_pet/app.dart';
import 'package:pocket_memory_pet/features/pet/application/elapsed_time_simulator.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/features/pet/data/hive_pet_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = await HivePetRepository.open();
  final storedSession = await repository.loadSession();
  final currentSession = const ElapsedTimeSimulator().apply(
    storedSession,
    DateTime.now().toUtc(),
  );
  await repository.saveSession(currentSession);

  runApp(
    ProviderScope(
      overrides: [
        petRepositoryProvider.overrideWithValue(repository),
        initialPetSessionProvider.overrideWithValue(currentSession),
      ],
      child: const PocketMemoryPetApp(),
    ),
  );
}
