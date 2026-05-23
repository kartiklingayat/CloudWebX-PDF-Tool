import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'services/auth/firebase_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Logger
  AppLogger.init();
  AppLogger.info('CloudWebX PDF Tool initialized');

  runApp(
    const ProviderScope(
      child: CloudWebXApp(),
    ),
  );
}

class CloudWebXApp extends ConsumerWidget {
  const CloudWebXApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode
    final themeMode = ref.watch(themeModeProvider);

    // Watch auth state
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'CloudWebX PDF Tool',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: authState.when(
        data: (user) {
          if (user != null) {
            AppLogger.info('User authenticated: ${user.email}');
            return const DashboardScreen();
          } else {
            AppLogger.info('No user authenticated');
            return const SplashScreen();
          }
        },
        loading: () => const SplashScreen(),
        error: (error, stack) {
          AppLogger.error('Auth state error', error, stack);
          return const SplashScreen();
        },
      ),
      onGenerateRoute: AppRoutes.generateRoute,
      navigatorObservers: [
        _NavigatorObserver(),
      ],
    );
  }
}

class _NavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    AppLogger.debug(
      'Navigated to: ${route.settings.name}',
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    AppLogger.debug(
      'Popped from: ${route.settings.name}',
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    AppLogger.debug(
      'Replaced ${oldRoute?.settings.name} with ${newRoute?.settings.name}',
    );
  }
}

// Theme Mode Provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

// Placeholder imports (replace with actual imports when files are created)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CloudWebX PDF Tool'),
      ),
      body: const Center(
        child: Text('Dashboard Screen'),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF00B894)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.description,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'CloudWebX PDF Tool',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Professional PDF Management',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
