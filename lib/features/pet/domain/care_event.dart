import 'package:pocket_memory_pet/features/pet/domain/pet_enums.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_state.dart';

class CareEvent {
  const CareEvent({
    required this.id,
    required this.createdAtUtc,
    required this.action,
    required this.valueDelta,
  });

  final String id;
  final DateTime createdAtUtc;
  final CareAction action;
  final Map<String, int> valueDelta;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAtUtc': createdAtUtc.toIso8601String(),
      'action': action.name,
      'valueDelta': valueDelta,
    };
  }

  factory CareEvent.fromJson(Map<String, dynamic> json) {
    final delta = (json['valueDelta'] as Map?)?.map(
          (key, value) => MapEntry(key.toString(), (value as num).toInt()),
        ) ??
        <String, int>{};

    return CareEvent(
      id: (json['id'] as String?) ?? 'event',
      createdAtUtc:
          utcDate(DateTime.tryParse((json['createdAtUtc'] as String?) ?? '') ?? DateTime.now()),
      action: CareAction.values.byName((json['action'] as String?) ?? CareAction.feedMeal.name),
      valueDelta: delta,
    );
  }
}
