
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';


class DecisionsPage extends StatefulWidget {
  const DecisionsPage({super.key});

  @override
  State<DecisionsPage> createState() => _DecisionsPageState();
}

class _DecisionsPageState extends State<DecisionsPage> {
  List<Map<String, dynamic>> decisions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDecisions();
  }

  Future<void> loadDecisions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
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

      if (!mounted) return;

      setState(() {
        decisions = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
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
      await loadDecisions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis decisiones'),
        actions: [
          IconButton(
            onPressed: loadDecisions,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 45),
            const SizedBox(height: 12),
            const Text('No se pudieron cargar las decisiones'),
            const SizedBox(height: 8),
            Text(errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loadDecisions,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (decisions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, size: 65),
            SizedBox(height: 15),
            Text(
              'Todavía no tienes decisiones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Crea tu primera decisión para comenzar.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadDecisions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: decisions.length,
        itemBuilder: (context, index) {
          final decision = decisions[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                child: Icon(Icons.lightbulb_outline),
              ),
              title: Text(
                decision['title'] ?? 'Sin título',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      decision['description'] ?? 'Sin descripción',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Categoría: ${decision['category'] ?? 'Sin categoría'}',
                    ),
                  ],
                ),
              ),
              trailing: IconButton(
                tooltip: 'Editar decisión',
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.indigo,
                ),
                onPressed: () {
                  _editDecision(decision);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
