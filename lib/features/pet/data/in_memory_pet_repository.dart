import 'package:pocket_memory_pet/features/pet/domain/pet_repository.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';

class InMemoryPetRepository implements PetRepository {
  InMemoryPetRepository({PetSession? seed})
      : _session = seed ?? PetSession.initial(DateTime.now().toUtc());

  PetSession _session;

  @override
  Future<PetSession> loadSession() async => _session;

  @override
  Future<void> saveSession(PetSession session) async {
    _session = session;
  }

  @override
  Future<PetSession> resetSession(DateTime nowUtc) async {
    _session = PetSession.initial(nowUtc);
    return _session;
  }
}
