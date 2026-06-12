import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/shared/layout/retro_screen_scaffold.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(petControllerProvider).inventory;
    return RetroScreenScaffold(
      title: 'Inventory',
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item.id),
            subtitle: Text(item.type.name),
            trailing: Text('x${item.quantity}'),
          );
        },
      ),
    );
  }
}
