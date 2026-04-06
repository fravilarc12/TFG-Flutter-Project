import 'dart:async'; // <--- NECESARIO para FutureOr
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/auth_repository.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // Estado inicial
  }

  Future<void> login(String email, String password) async {
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repository.signInWithEmailAndPassword(email, password),
    );
  }

  Future<void> register(String email, String password) async {
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repository.createUserWithEmailAndPassword(email, password),
    );
  }

  Future<void> signInWithGoogle() async {
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repository.signInWithGoogle(),
    );
  }

  Future<void> recoverPassword(String email) async {
    final repository = ref.read(authRepositoryProvider);
    // No cambiamos "state" aquí porque si pasa a AsyncData, la UI navega al Home.
    await repository.sendPasswordResetEmail(email);
  }

  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
    // Al cerrar sesión, el estado pasa a null o inicial, y la UI reaccionará
  }
}
