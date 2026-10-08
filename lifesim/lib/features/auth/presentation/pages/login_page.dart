import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      return;
    }

    await ref.read(authProvider.notifier).login(
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'LifeSim',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.go('/forgot-password');
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: login,
                  child: const Text('Iniciar sesión'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  context.go('/register');
                },
                child: const Text(
                  'Crear una cuenta',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}