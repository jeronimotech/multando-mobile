import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'features/achievements/screens/achievements_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/reports/screens/new_report_screen.dart';
import 'features/reports/screens/report_detail_screen.dart';
import 'features/reports/screens/reports_list_screen.dart';
import 'features/verify/screens/verify_screen.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/wallet/screens/wallet_screen.dart';

/// GoRouter configuration with auth guard.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  final onboardingComplete = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = auth.status == AuthStatus.authenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/onboarding';

      // Show onboarding first time
      if (!onboardingComplete && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }

      // Redirect unauthenticated users to login
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // Redirect authenticated users away from auth screens
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),

      // Main app routes
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (_, __) => const ReportsListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (_, __) => const NewReportScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) => ReportDetailScreen(
              reportId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/verify',
        builder: (_, __) => const VerifyScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (_, __) => const WalletScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (_, __) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (_, __) => const ChatScreen(),
      ),
    ],
  );
});

/// The root MaterialApp widget.
class MultandoApp extends ConsumerWidget {
  const MultandoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Multando',
      debugShowCheckedModeBanner: false,
      theme: MultandoTheme.light,
      darkTheme: MultandoTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
    );
  }
}
