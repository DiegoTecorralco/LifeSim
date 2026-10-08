import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class ProfilePage
    extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final user =
        ref.watch(authProvider).value;

    final fullName =
        user?.fullName?.isNotEmpty == true
            ? user!.fullName!
            : 'No disponible';

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Mi perfil'),
      ),
      body: Center(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 600,
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundColor:
                      Colors.indigo,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color:
                        Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                Text(
                  fullName,
                  style:
                      const TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  user?.email ??
                      'No disponible',
                  style:
                      const TextStyle(
                    color:
                        Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                Card(
                  elevation: 0,
                  child: Column(
                    children: [
                      ListTile(
                        leading:
                            const Icon(
                          Icons
                              .person_outline,
                        ),
                        title:
                            const Text(
                          'Nombre completo',
                        ),
                        subtitle:
                            Text(
                          fullName,
                        ),
                      ),

                      const Divider(
                        height: 1,
                      ),

                      ListTile(
                        leading:
                            const Icon(
                          Icons
                              .email_outlined,
                        ),
                        title:
                            const Text(
                          'Correo electrónico',
                        ),
                        subtitle:
                            Text(
                          user?.email ??
                              'No disponible',
                        ),
                      ),

                      const Divider(
                        height: 1,
                      ),

                      ListTile(
                        leading:
                            const Icon(
                          Icons
                              .badge_outlined,
                        ),
                        title:
                            const Text(
                          'ID de usuario',
                        ),
                        subtitle:
                            Text(
                          user?.id ??
                              'No disponible',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 50,
                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      context.go(
                        '/dashboard',
                      );
                    },
                    icon:
                        const Icon(
                      Icons.arrow_back,
                    ),
                    label:
                        const Text(
                      'Volver al dashboard',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 50,
                  child:
                      FilledButton.icon(
                    onPressed:
                        () async {
                      await ref
                          .read(
                            authProvider
                                .notifier,
                          )
                          .logout();

                      if (!context
                          .mounted) {
                        return;
                      }

                      context.go(
                        '/login',
                      );
                    },
                    icon:
                        const Icon(
                      Icons.logout,
                    ),
                    label:
                        const Text(
                      'Cerrar sesión',
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