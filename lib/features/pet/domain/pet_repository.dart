import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';

abstract interface class PetRepository {
  Future<PetSession> loadSession();

  Future<void> saveSession(PetSession session);

  Future<PetSession> resetSession(DateTime nowUtc);
}
