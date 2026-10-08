import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class RegisterPage
    extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends ConsumerState<RegisterPage> {
  final fullNameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmController =
      TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    final fullName =
        fullNameController.text.trim();

    final email =
        emailController.text.trim();

    final password =
        passwordController.text.trim();

    final confirm =
        confirmController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      _showMessage(
        'Completa todos los campos',
      );
      return;
    }

    if (fullName.length < 3) {
      _showMessage(
        'El nombre completo debe tener al menos 3 caracteres',
      );
      return;
    }

    if (password.length < 6) {
      _showMessage(
        'La contraseña debe tener mínimo 6 caracteres',
      );
      return;
    }

    if (password != confirm) {
      _showMessage(
        'Las contraseñas no coinciden',
      );
      return;
    }

    await ref
        .read(authProvider.notifier)
        .register(
          fullName: fullName,
          email: email,
          password: password,
        );

    final state =
        ref.read(authProvider);

    if (!mounted) return;

    if (state.hasError) {
      _showMessage(
        state.error.toString(),
      );
      return;
    }

    _showMessage(
      'Cuenta creada correctamente',
    );

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    context.go('/login');
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState =
        ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear cuenta',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 430,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 65,
                  color: Colors.indigo,
                ),

                const SizedBox(
                  height: 20,
                ),

                const Text(
                  'Crear cuenta',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(
                  'Crea tu cuenta para comenzar a utilizar LifeSim',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 32,
                ),

                TextField(
                  controller:
                      fullNameController,
                  textCapitalization:
                      TextCapitalization
                          .words,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Nombre completo',
                    hintText:
                        'Ej. Diego Tecorralco',
                    prefixIcon:
                        Icon(
                      Icons
                          .person_outline,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextField(
                  controller:
                      emailController,
                  keyboardType:
                      TextInputType
                          .emailAddress,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Correo electrónico',
                    hintText:
                        'correo@ejemplo.com',
                    prefixIcon:
                        Icon(
                      Icons
                          .email_outlined,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextField(
                  controller:
                      passwordController,
                  obscureText:
                      obscurePassword,
                  decoration:
                      InputDecoration(
                    labelText:
                        'Contraseña',
                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),
                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword =
                              !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons
                                .visibility_outlined
                            : Icons
                                .visibility_off_outlined,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextField(
                  controller:
                      confirmController,
                  obscureText:
                      obscurePassword,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Confirmar contraseña',
                    prefixIcon:
                        Icon(
                      Icons.lock_outline,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed:
                        authState.isLoading
                            ? null
                            : _register,
                    child:
                        authState.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Text(
                                'Crear cuenta',
                              ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextButton(
                  onPressed: () {
                    context.go(
                      '/login',
                    );
                  },
                  child:
                      const Text(
                    'Ya tengo una cuenta',
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