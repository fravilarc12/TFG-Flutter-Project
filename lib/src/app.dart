import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // Importante para Plus Jakarta Sans
import 'routing/app_router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'TravelHub',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF005D90),
          primary: const Color(0xFF005D90),
          primaryContainer: const Color(0xFF0077B6),
          secondary: const Color(0xFF45617B),
          surface: const Color(0xFFF8F9FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        textTheme: baseTextTheme,
      ),
      themeMode: ThemeMode.light,
    );
  }
}
