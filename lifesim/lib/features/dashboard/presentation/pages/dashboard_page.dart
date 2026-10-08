import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeSim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              context.go('/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref
                  .read(authProvider.notifier)
                  .logout();

              if (!context.mounted) return;

              context.go('/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Bienvenido a LifeSim',
        ),
      ),
    );
  }
}