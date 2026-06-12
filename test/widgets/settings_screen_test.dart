import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/features/pet/data/in_memory_pet_repository.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';
import 'package:pocket_memory_pet/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen shows local reminder explanation before permission', (tester) async {
    final now = DateTime.parse('2026-06-12T00:00:00Z');
    final session = PetSession.initial(now);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          petRepositoryProvider.overrideWithValue(InMemoryPetRepository(seed: session)),
          initialPetSessionProvider.overrideWithValue(session),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();

    expect(find.text('Enable gentle reminders?'), findsOneWidget);
    expect(find.textContaining('only uses local reminders'), findsOneWidget);
  });
}
