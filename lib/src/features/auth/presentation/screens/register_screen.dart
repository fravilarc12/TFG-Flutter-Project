import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Usamos controladores persistente
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController; // Nuevo campo
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado global
    ref.listen(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        final errorString = next.error.toString().toLowerCase();
        String translatedMessage = 'Ocurrió un error en el registro. Inténtalo de nuevo.';
        
        if (errorString.contains('weak-password')) {
          translatedMessage = 'La contraseña es demasiado corta (mínimo 6 caracteres).';
        } else if (errorString.contains('email-already-in-use')) {
          translatedMessage = 'Ese correo electrónico ya está registrado.';
        } else if (errorString.contains('invalid-email')) {
          translatedMessage = 'El formato del correo no es válido.';
        } else if (errorString.contains('network-request-failed')) {
          translatedMessage = 'Error de conexión. Comprueba tu internet.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translatedMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Si el registro es exitoso, GoRouter nos llevará al Home automáticamente
      // gracias a la lógica de redirección que pondremos en el router
      if (next is AsyncData && !next.isLoading) {
        // Opcional: Mostrar un mensaje de éxito antes de navegar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Cuenta creada con éxito!')),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(), // Volver al login
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crear Cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Únete para empezar a viajar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 48),

              // EMAIL
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),

              // PASSWORD
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),

              // CONFIRM PASSWORD
              TextField(
                controller: confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 32),

              // BOTÓN REGISTRAR
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        // 1. Validaciones UI locales
                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Las contraseñas no coinciden'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        // 2. Llamada al backend
                        FocusScope.of(context).unfocus();
                        ref.read(authControllerProvider.notifier).register(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Registrarse',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              // SEPARADOR
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'o regístrate con',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
              ),

              // BOTÓN GOOGLE
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: Colors.white,
                ),
                onPressed: isLoading
                    ? null
                    : () {
                        FocusScope.of(context).unfocus();
                        ref
                            .read(authControllerProvider.notifier)
                            .signInWithGoogle();
                      },
                icon: Image.network(
                  'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                  height: 22,
                  width: 22,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.g_mobiledata, size: 22, color: Color(0xFF4285F4)),
                ),
                label: const Text(
                  'Continuar con Google',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
