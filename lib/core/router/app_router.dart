import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/call/screens/call_screen.dart';
import '../../features/report/screens/report_screen.dart';
import '../../features/memory/screens/memory_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/main_shell.dart';
import '../../shared/providers/app_providers.dart';
import '../../core/models/app_models.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isOnboarded = ref.watch(isOnboardedProvider);
  final isLoggedIn = ref.watch(isLoggedInProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final onSplash = state.matchedLocation == '/splash';
      if (onSplash) return null;
      if (!isOnboarded) return '/onboarding';
      if (!isLoggedIn) return '/onboarding';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/memory',
            builder: (context, state) => const MemoryScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/call',
        builder: (context, state) => const CallScreen(),
      ),
      GoRoute(
        path: '/report/:callId',
        builder: (context, state) {
          final extra = state.extra as CallSession?;
          return ReportScreen(session: extra);
        },
      ),
    ],
  );
});
