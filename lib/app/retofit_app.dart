import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/storage/local_storage_service.dart';
import '../core/theme/app_theme.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/nutrition/nutrition_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/workouts/workouts_screen.dart';
import 'app_state.dart';

class RetoFitApp extends StatefulWidget {
  const RetoFitApp({required this.storage, super.key});

  final LocalStorageService storage;

  @override
  State<RetoFitApp> createState() => _RetoFitAppState();
}

class _RetoFitAppState extends State<RetoFitApp> {
  late final Future<RetoFitState> _stateFuture;

  @override
  void initState() {
    super.initState();
    _stateFuture = widget.storage.load().then(
          (snapshot) => RetoFitState(
            storage: widget.storage,
            snapshot: snapshot,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RetoFitState>(
      future: _stateFuture,
      builder: (context, snapshot) {
        return MaterialApp(
          title: 'RetoFit 30',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          locale: const Locale('es', 'MX'),
          supportedLocales: const [Locale('es', 'MX')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: switch (snapshot.connectionState) {
            ConnectionState.done when snapshot.hasData => RetoFitScope(
                state: snapshot.data!,
                child: const _EntryGate(),
              ),
            _ => const _Splash(),
          },
        );
      },
    );
  }
}

class _EntryGate extends StatelessWidget {
  const _EntryGate();

  @override
  Widget build(BuildContext context) {
    final state = RetoFitScope.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return state.hasProfile ? const MainShell() : const OnboardingScreen();
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    WorkoutsScreen(),
    NutritionScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Entrenar',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Nutrición',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progreso',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
