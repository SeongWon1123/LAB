import 'package:flutter/material.dart';
import 'package:pocket_memory_pet/core/routing/app_router.dart';
import 'package:pocket_memory_pet/core/theme/app_theme.dart';

class PocketMemoryPetApp extends StatelessWidget {
  const PocketMemoryPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pocket Memory Pet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
