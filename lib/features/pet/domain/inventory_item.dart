import 'package:pocket_memory_pet/features/pet/domain/pet_enums.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_state.dart';

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.type,
    required this.quantity,
    required this.unlockedAtUtc,
  });

  final String id;
  final InventoryItemType type;
  final int quantity;
  final DateTime unlockedAtUtc;

  InventoryItem copyWith({
    String? id,
    InventoryItemType? type,
    int? quantity,
    DateTime? unlockedAtUtc,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unlockedAtUtc: utcDate(unlockedAtUtc ?? this.unlockedAtUtc),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'quantity': quantity,
      'unlockedAtUtc': unlockedAtUtc.toIso8601String(),
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: (json['id'] as String?) ?? 'item',
      type: InventoryItemType.values.byName(
        (json['type'] as String?) ?? InventoryItemType.keepsake.name,
      ),
      quantity: (json['quantity'] as int?) ?? 1,
      unlockedAtUtc:
          utcDate(DateTime.tryParse((json['unlockedAtUtc'] as String?) ?? '') ?? DateTime.now()),
    );
  }
}
