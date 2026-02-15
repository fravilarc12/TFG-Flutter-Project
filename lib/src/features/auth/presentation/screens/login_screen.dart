import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';

// 1. Cambiamos a ConsumerStatefulWidget para tener "memoria"
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // 2. Definimos los controladores AQUÍ (fuera del build)
  // Así sobreviven cuando sale el teclado
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // 3. Limpiamos la memoria cuando cerramos la pantalla
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4. Escuchamos los cambios de estado (Login éxito o error)
    ref.listen(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.error.toString().replaceAll('Exception:', '').trim(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Si el login es exitoso, nos vamos a la Home ('/')
      if (next is AsyncData && !next.isLoading) {
        context.go('/');
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // Center para asegurar que se ve bien al rotar o con teclado
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.flight_takeoff_rounded,
                size: 80,
                color: Color(0xFF0066CC),
              ),
              const SizedBox(height: 16),
              Text(
                'TravelPlanner',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Planifica tu próxima aventura',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 48),

              // CAMPO EMAIL
              TextField(
                controller:
                    emailController, // Usamos el controlador persistente
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),

              // CAMPO PASSWORD
              TextField(
                controller:
                    passwordController, // Usamos el controlador persistente
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outlined),
                  suffixIcon: Icon(Icons.visibility_off_outlined),
                ),
                enabled: !isLoading,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading ? null : () {},
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),
              const SizedBox(height: 24),

              // BOTÓN LOGIN
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        // Ocultar teclado al pulsar
                        FocusScope.of(context).unfocus();

                        ref.read(authControllerProvider.notifier).login(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No tienes cuenta?',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed:
                        isLoading ? null : () => context.push('/register'),
                    child: const Text('Regístrate aquí'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
