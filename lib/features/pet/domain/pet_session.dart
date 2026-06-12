import 'package:pocket_memory_pet/features/pet/domain/care_event.dart';
import 'package:pocket_memory_pet/features/pet/domain/diary_entry.dart';
import 'package:pocket_memory_pet/features/pet/domain/inventory_item.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_enums.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_state.dart';

class PetSession {
  const PetSession({
    required this.pet,
    required this.inventory,
    required this.diary,
    required this.careEvents,
    required this.notificationsEnabled,
    required this.soundEnabled,
  });

  factory PetSession.initial(DateTime nowUtc) {
    final now = utcDate(nowUtc);
    return PetSession(
      pet: PetState.initial(now),
      inventory: [
        InventoryItem(
          id: 'meal-basic',
          type: InventoryItemType.food,
          quantity: 99,
          unlockedAtUtc: now,
        ),
      ],
      diary: [
        DiaryEntry(
          id: 'welcome-${now.microsecondsSinceEpoch}',
          createdAtUtc: now,
          type: DiaryEntryType.system,
          title: 'A little toy box is waiting',
          body: 'Name your tiny friend and open the warm LCD screen.',
          iconId: 'box',
        ),
      ],
      careEvents: const [],
      notificationsEnabled: false,
      soundEnabled: true,
    );
  }

  final PetState pet;
  final List<InventoryItem> inventory;
  final List<DiaryEntry> diary;
  final List<CareEvent> careEvents;
  final bool notificationsEnabled;
  final bool soundEnabled;

  PetSession copyWith({
    PetState? pet,
    List<InventoryItem>? inventory,
    List<DiaryEntry>? diary,
    List<CareEvent>? careEvents,
    bool? notificationsEnabled,
    bool? soundEnabled,
  }) {
    return PetSession(
      pet: pet ?? this.pet,
      inventory: inventory ?? this.inventory,
      diary: diary ?? this.diary,
      careEvents: careEvents ?? this.careEvents,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet': pet.toJson(),
      'inventory': inventory.map((item) => item.toJson()).toList(),
      'diary': diary.map((entry) => entry.toJson()).toList(),
      'careEvents': careEvents.map((event) => event.toJson()).toList(),
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
    };
  }

  factory PetSession.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().toUtc();
    return PetSession.initial(now).copyWith(
      pet: PetState.fromJson(Map<String, dynamic>.from(json['pet'] as Map? ?? {})),
      inventory: (json['inventory'] as List? ?? [])
          .whereType<Map>()
          .map((item) => InventoryItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      diary: (json['diary'] as List? ?? [])
          .whereType<Map>()
          .map((entry) => DiaryEntry.fromJson(Map<String, dynamic>.from(entry)))
          .toList(),
      careEvents: (json['careEvents'] as List? ?? [])
          .whereType<Map>()
          .map((event) => CareEvent.fromJson(Map<String, dynamic>.from(event)))
          .toList(),
      notificationsEnabled: json['notificationsEnabled'] as bool?,
      soundEnabled: json['soundEnabled'] as bool?,
    );
  }
}
