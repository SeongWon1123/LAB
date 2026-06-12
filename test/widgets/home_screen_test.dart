import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_memory_pet/features/home/presentation/home_screen.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/features/pet/data/in_memory_pet_repository.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';

void main() {
  testWidgets('HomeScreen renders retro device and changes menu', (tester) async {
    final now = DateTime.parse('2026-06-12T00:00:00Z');
    final base = PetSession.initial(now);
    final session = base.copyWith(pet: base.pet.copyWith(name: 'Cloudy'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          petRepositoryProvider.overrideWithValue(InMemoryPetRepository(seed: session)),
          initialPetSessionProvider.overrideWithValue(session),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Pocket Memory Pet'), findsWidgets);
    expect(find.text('Meal'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Right'));
    await tester.pump();

    expect(find.text('Snack'), findsOneWidget);
  });
}
