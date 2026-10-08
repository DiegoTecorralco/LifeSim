import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LifeSim',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            onPressed: () {
              context.go('/profile');
            },
            icon: const Icon(
              Icons.person_outline,
            ),
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.indigo,
              ),
              accountName: const Text(
                'Usuario LifeSim',
              ),
              accountEmail: Text(
                user?.email ?? 'Sin correo',
              ),
              currentAccountPicture:
                  const CircleAvatar(
                child: Icon(
                  Icons.person,
                  size: 35,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(
                Icons.dashboard_outlined,
              ),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.person_outline,
              ),
              title: const Text('Mi perfil'),
              onTap: () {
                Navigator.pop(context);
                context.go('/profile');
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.logout,
              ),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await ref
                    .read(authProvider.notifier)
                    .logout();

                if (!context.mounted) return;

                context.go('/login');
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1100,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${user?.email ?? 'usuario'}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  '¿Qué decisión quieres simular hoy?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            size: 45,
                            color: Colors.indigo,
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'Nueva decisión',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Crea una decisión y posteriormente agrega variables y escenarios para simular sus posibles resultados.',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 20),

                          FilledButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Módulo de decisiones próximamente',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.add,
                            ),
                            label: const Text(
                              'Crear decisión',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Mis decisiones',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 55,
                            color: Colors.grey.shade400,
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Todavía no tienes decisiones',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'Tus decisiones aparecerán aquí.',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
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