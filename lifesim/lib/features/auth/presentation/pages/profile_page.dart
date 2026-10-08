import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final userState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
      ),
      body: userState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text(
            error.toString(),
          ),
        ),
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text(
                'No hay una sesión activa',
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Correo electrónico',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(user.email),
                const SizedBox(height: 24),
                Text(
                  'ID: ${user.id}',
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(authProvider.notifier)
                        .logout();

                    if (!context.mounted) return;

                    context.go('/login');
                  },
                  child: const Text(
                    'Cerrar sesión',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}