import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  AuthRepository(this._auth) : _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signInWithEmailAndPassword(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Inicia sesión con Google. Funciona tanto para login como para registro:
  /// Firebase crea la cuenta automáticamente si no existe.
  Future<void> signInWithGoogle() async {
    // Abre el selector de cuentas de Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // El usuario canceló el flujo
      throw Exception('Inicio de sesión con Google cancelado.');
    }

    // Obtiene los tokens de autenticación
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Crea las credenciales de Firebase
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Inicia sesión en Firebase
    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    // Desconectar también de Google para que el selector aparezca la próxima vez
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

// ESTA PARTE ES CRÍTICA: Asegúrate de que @riverpod esté aquí
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(FirebaseAuth.instance);
}
