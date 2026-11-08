
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  late Future<List<Map<String, dynamic>>> _decisionsFuture;

  @override
  void initState() {
    super.initState();
    _decisionsFuture = loadDecisions();
  }

  Future<List<Map<String, dynamic>>> loadDecisions() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('No hay un usuario autenticado.');
    }

    final response = await supabase
        .from('decisions')
        .select('id, title, description, category, created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  void refreshDecisions() {
    setState(() {
      _decisionsFuture = loadDecisions();
    });
  }

  Future<void> _editDecision(
    Map<String, dynamic> decision,
  ) async {
    final result = await context.push<bool>(
      '/decisions/edit',
      extra: decision,
    );

    if (!mounted) return;

    if (result == true) {
      refreshDecisions();
    }
  }

  // ELIMINAR DECISIÓN
  Future<void> _deleteDecision(
    Map<String, dynamic> decision,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar decisión'),
          content: Text(
            '¿Estás seguro de que deseas eliminar '
            '"${decision['title']}"? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para eliminar decisiones.'),
        ),
      );
      return;
    }

    try {
      final deletedRows = await supabase
          .from('decisions')
          .delete()
          .eq('id', decision['id'])
          .eq('user_id', user.id)
          .select('id');

      if (!mounted) return;

      if (deletedRows.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo eliminar la decisión. '
              'Verifica los permisos de Supabase.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      refreshDecisions();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Decisión eliminada correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar la decisión: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;

    final displayName = user?.fullName?.isNotEmpty == true
        ? user!.fullName!
        : 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LifeSim',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            onPressed: () {
              context.go('/profile');
            },
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              accountName: Text(displayName),
              accountEmail: Text(user?.email ?? 'Sin correo'),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person, size: 35),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Mi perfil'),
              onTap: () {
                Navigator.pop(context);
                context.go('/profile');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();

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
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $displayName',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '¿Qué decisión quieres simular hoy?',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Crea una decisión y posteriormente agrega variables y escenarios para simular sus posibles resultados.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () async {
                              final result = await context.push<bool>(
                                '/decisions/create',
                              );

                              if (!mounted) return;

                              if (result == true) {
                                refreshDecisions();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Crear decisión'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mis decisiones',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Actualizar decisiones',
                      onPressed: refreshDecisions,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _decisionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 45,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No se pudieron cargar las decisiones.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: refreshDecisions,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final decisions = snapshot.data ?? [];

                    if (decisions.isEmpty) {
                      return Card(
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
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Tus decisiones aparecerán aquí.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: decisions.map((decision) {
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFE8EAF6),
                              child: Icon(
                                Icons.lightbulb_outline,
                                color: Colors.indigo,
                              ),
                            ),
                            title: Text(
                              decision['title'] ?? 'Sin título',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    decision['description'] ?? '',
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Categoría: ${decision['category'] ?? 'Sin categoría'}',
                                    style: const TextStyle(
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // BOTONES DE VARIABLES, EDICIÓN Y ELIMINACIÓN
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Ver variables',
                                  icon: const Icon(
                                    Icons.tune,
                                    color: Colors.teal,
                                  ),
                                  onPressed: () {
                                    context.push(
                                      '/decisions/variables',
                                      extra: decision,
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Editar decisión',
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.indigo,
                                  ),
                                  onPressed: () {
                                    _editDecision(decision);
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Eliminar decisión',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    _deleteDecision(decision);
                                  },
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
