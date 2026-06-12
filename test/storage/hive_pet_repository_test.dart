import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:pocket_memory_pet/features/pet/data/hive_pet_repository.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pocket_memory_pet_hive_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('HivePetRepository saves, loads, and resets a session', () async {
    final now = DateTime.parse('2026-06-12T00:00:00Z');
    final box = await Hive.openBox<dynamic>('session_test');
    final repository = HivePetRepository(box);
    final base = PetSession.initial(now);
    final changed = base.copyWith(pet: base.pet.copyWith(name: 'Cloudy'));

    await repository.saveSession(changed);
    final loaded = await repository.loadSession();

    expect(loaded.pet.name, 'Cloudy');

    final reset = await repository.resetSession(now);

    expect(reset.pet.name, isEmpty);
    expect((await repository.loadSession()).pet.name, isEmpty);
  });
}
