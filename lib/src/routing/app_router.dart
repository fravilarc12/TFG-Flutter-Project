import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/trips/presentation/screens/home_screen.dart';
import '../features/trips/presentation/screens/trip_details_screen.dart';
import '../features/auth/data/auth_repository.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/login', // La app arrancará aquí
    redirect: (context, state) async {
      final user = await ref.read(authRepositoryProvider).authStateChanges().first;
      final isLoggedIn = user != null;
      
      final isGoingToAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (isLoggedIn && isGoingToAuth) {
        return '/';
      }
      if (!isLoggedIn && !isGoingToAuth) {
        return '/login';
      }
      return null;
    },
    routes: [
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



      GoRoute(
        path: '/trip/:tripId',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return TripDetailsScreen(tripId: tripId);
        },
      ),
    ],
  );
}
