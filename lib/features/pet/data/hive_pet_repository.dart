import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:pocket_memory_pet/core/storage/storage_keys.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_repository.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';

class HivePetRepository implements PetRepository {
  const HivePetRepository._(this._box);

  final Box<dynamic> _box;

  static Future<HivePetRepository> open() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<dynamic>(StorageKeys.sessionBox);
    return HivePetRepository._(box);
  }

  @override
  Future<PetSession> loadSession() async {
    final raw = _box.get(StorageKeys.session);
    if (raw is Map) {
      return PetSession.fromJson(Map<String, dynamic>.from(raw));
    }

    final session = PetSession.initial(DateTime.now().toUtc());
    await saveSession(session);
    return session;
  }

  @override
  Future<void> saveSession(PetSession session) async {
    await _box.put(StorageKeys.session, session.toJson());
  }

  @override
  Future<PetSession> resetSession(DateTime nowUtc) async {
    final session = PetSession.initial(nowUtc);
    await saveSession(session);
    return session;
  }
}
