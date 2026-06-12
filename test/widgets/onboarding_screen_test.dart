import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_memory_pet/features/onboarding/presentation/onboarding_screen.dart';
import 'package:pocket_memory_pet/features/pet/application/pet_controller.dart';
import 'package:pocket_memory_pet/features/pet/data/in_memory_pet_repository.dart';
import 'package:pocket_memory_pet/features/pet/domain/pet_session.dart';

void main() {
  testWidgets('OnboardingScreen requires a pet name before continuing', (tester) async {
    final now = DateTime.parse('2026-06-12T00:00:00Z');
    final session = PetSession.initial(now);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          petRepositoryProvider.overrideWithValue(InMemoryPetRepository(seed: session)),
          initialPetSessionProvider.overrideWithValue(session),
        ],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    await tester.tap(find.text('Find the tiny friend'));
    await tester.pump();

    expect(find.text('Choose a pet name first.'), findsOneWidget);
  });
}
