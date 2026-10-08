import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends ConsumerState<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController =
      TextEditingController();

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword =
        confirmPasswordController.text;

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Las contraseñas no coinciden',
          ),
        ),
      );
      return;
    }

    await ref
        .read(authProvider.notifier)
        .register(
          email: email,
          password: password,
        );

    if (!mounted) return;

    final state = ref.read(authProvider);

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error.toString(),
          ),
        ),
      );
      return;
    }

    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: register,
                child: const Text('Registrarme'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}