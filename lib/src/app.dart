import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routing/app_router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Travel Planner',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0066CC),
        brightness: Brightness.light,
        // Eliminamos el bloque problemático de cardTheme y dejamos que
        // Material 3 lo gestione con el colorSchemeSeed.
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0066CC),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
