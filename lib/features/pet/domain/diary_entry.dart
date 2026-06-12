import 'package:pocket_memory_pet/features/pet/domain/pet_enums.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_state.dart';

class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.createdAtUtc,
    required this.type,
    required this.title,
    required this.body,
    required this.iconId,
  });

  final String id;
  final DateTime createdAtUtc;
  final DiaryEntryType type;
  final String title;
  final String body;
  final String iconId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAtUtc': createdAtUtc.toIso8601String(),
      'type': type.name,
      'title': title,
      'body': body,
      'iconId': iconId,
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: (json['id'] as String?) ?? 'entry',
      createdAtUtc:
          utcDate(DateTime.tryParse((json['createdAtUtc'] as String?) ?? '') ?? DateTime.now()),
      type: DiaryEntryType.values.byName(
        (json['type'] as String?) ?? DiaryEntryType.system.name,
      ),
      title: (json['title'] as String?) ?? 'Memory',
      body: (json['body'] as String?) ?? '',
      iconId: (json['iconId'] as String?) ?? 'sparkle',
    );
  }
}
