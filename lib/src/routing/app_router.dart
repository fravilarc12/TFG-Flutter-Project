import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/trips/presentation/screens/home_screen.dart';
import '../features/trips/presentation/screens/trip_details_screen.dart';

// Este archivo es el que genera Riverpod automáticamente
part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/login', // La app arrancará aquí
    routes: [
      // Ruta al Login (Conectada a tu diseño real)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),

      // Ruta al Home (Todavía es un placeholder)
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Pantalla de Inicio - Viajes')),
        ),
      ),

      GoRoute(
        path: '/trip/:tripId', // El :tripId es un parámetro variable
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return TripDetailsScreen(tripId: tripId);
        },
      ),
    ],
  );
}
