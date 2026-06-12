import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_memory_pet/features/pet/data/in_memory_pet_repository.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';

void main() {
  test('InMemoryPetRepository saves and loads a session', () async {
    final now = DateTime.parse('2026-06-12T00:00:00Z');
    final repository = InMemoryPetRepository(seed: PetSession.initial(now));
    final base = PetSession.initial(now);
    final changed = base.copyWith(pet: base.pet.copyWith(name: 'Cloudy'));

    await repository.saveSession(changed);
    final loaded = await repository.loadSession();

    expect(loaded.pet.name, 'Cloudy');
  });
}
