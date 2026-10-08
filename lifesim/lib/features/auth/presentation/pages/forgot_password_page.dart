import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends ConsumerState<ForgotPasswordPage> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendRecovery() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Introduce tu correo');
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .resetPassword(email);

      if (!mounted) return;

      _showMessage(
        'Si el correo existe, recibirás instrucciones para recuperar tu contraseña',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString(),
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_reset,
                  size: 70,
                  color: Colors.indigo,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Recuperar contraseña',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Introduce tu correo electrónico y te enviaremos las instrucciones para recuperar el acceso.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 32),

                TextField(
                  controller: emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon:
                        Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _sendRecovery,
                    child: const Text(
                      'Enviar instrucciones',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text(
                    'Volver al inicio de sesión',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}