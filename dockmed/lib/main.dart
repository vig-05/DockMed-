import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/user_provider.dart';
import 'providers/records_provider.dart';
import 'providers/vitals_provider.dart';
import 'providers/medications_provider.dart';
import 'providers/appointments_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/account_creation_screen.dart';
import 'screens/main/home_screen.dart';
import 'screens/main/records_screen.dart';
import 'screens/main/medications_screen.dart';
import 'screens/main/body_screen.dart';
import 'screens/main/appointments_screen.dart';
import 'screens/main/profile_screen.dart';
import 'screens/features/vitals_screen.dart';
import 'screens/features/consent_screen.dart';
import 'screens/features/emergency_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RecordsProvider()),
        ChangeNotifierProvider(create: (_) => VitalsProvider()),
        ChangeNotifierProvider(create: (_) => MedicationsProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/records')) return 1;
    if (location.startsWith('/body')) return 2;
    if (location.startsWith('/medication')) return 3;
    if (location.startsWith('/appointments')) return 4;
    if (location.startsWith('/profile')) return 5;
    return 0; // Default to home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/app');
        break;
      case 1:
        context.go('/records');
        break;
      case 2:
        context.go('/body');
        break;
      case 3:
        context.go('/medication');
        break;
      case 4:
        context.go('/appointments');
        break;
      case 5:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _calculateSelectedIndex(context),
            onTap: (index) => _onItemTapped(index, context),
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: Colors.grey.shade400,
            backgroundColor: Colors.white,
            elevation: 0,
            showUnselectedLabels: true,
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.folder_shared_rounded), label: 'Records'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_rounded), label: 'Body'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.medication_rounded), label: 'Meds'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_rounded), label: 'Appts'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: '/account-creation',
      builder: (context, state) => const AccountCreationScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/app',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'vitals',
              builder: (context, state) => const VitalsScreen(),
            ),
            GoRoute(
              path: 'consent',
              builder: (context, state) => const ConsentScreen(),
            ),
            GoRoute(
              path: 'emergency',
              builder: (context, state) => const EmergencyScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/records',
          builder: (context, state) => const RecordsScreen(),
        ),
        GoRoute(
          path: '/body',
          builder: (context, state) => const BodyScreen(),
        ),
        GoRoute(
          path: '/medication',
          builder: (context, state) => const MedicationsScreen(),
        ),
        GoRoute(
          path: '/appointments',
          builder: (context, state) => const AppointmentsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DockMed',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
