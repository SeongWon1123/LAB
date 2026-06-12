import 'package:go_router/go_router.dart';
import 'package:pocket_memory_pet/features/diary/presentation/diary_screen.dart';
import 'package:pocket_memory_pet/features/hatch/presentation/hatch_screen.dart';
import 'package:pocket_memory_pet/features/home/presentation/home_screen.dart';
import 'package:pocket_memory_pet/features/inventory/presentation/inventory_screen.dart';
import 'package:pocket_memory_pet/features/minigame/presentation/play_screen.dart';
import 'package:pocket_memory_pet/features/onboarding/presentation/onboarding_screen.dart';
import 'package:pocket_memory_pet/features/settings/presentation/settings_screen.dart';
import 'package:pocket_memory_pet/features/status/presentation/status_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(path: '/', redirect: (_, _) => '/onboarding'),
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    GoRoute(path: '/hatch', builder: (_, _) => const HatchScreen()),
    GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/status', builder: (_, _) => const StatusScreen()),
    GoRoute(path: '/feed', builder: (_, _) => const HomeScreen(initialMenu: HomeMenu.meal)),
    GoRoute(path: '/play', builder: (_, _) => const PlayScreen()),
    GoRoute(path: '/clean', builder: (_, _) => const HomeScreen(initialMenu: HomeMenu.clean)),
    GoRoute(path: '/sleep', builder: (_, _) => const HomeScreen(initialMenu: HomeMenu.sleep)),
    GoRoute(path: '/diary', builder: (_, _) => const DiaryScreen()),
    GoRoute(path: '/inventory', builder: (_, _) => const InventoryScreen()),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
  ],
);
