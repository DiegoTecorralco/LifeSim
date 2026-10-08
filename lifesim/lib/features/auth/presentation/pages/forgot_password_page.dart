import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class ForgotPasswordPage
    extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends ConsumerState<ForgotPasswordPage> {
  final emailController = TextEditingController();

  Future<void> sendRecoveryEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .resetPassword(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Se ha enviado el correo de recuperación',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recuperar contraseña',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Ingresa tu correo electrónico para '
              'recibir instrucciones para recuperar '
              'tu contraseña.',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sendRecoveryEmail,
                child: const Text(
                  'Enviar correo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}