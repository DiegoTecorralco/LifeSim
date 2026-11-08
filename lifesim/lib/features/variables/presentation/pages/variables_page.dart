
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class VariablesPage extends StatefulWidget {
  final Map<String, dynamic> decision;

  const VariablesPage({
    super.key,
    required this.decision,
  });

  @override
  State<VariablesPage> createState() => _VariablesPageState();
}

class _VariablesPageState extends State<VariablesPage> {
  late Future<List<Map<String, dynamic>>> _variablesFuture;

  @override
  void initState() {
    super.initState();
    _variablesFuture = _loadVariables();
  }

  Future<List<Map<String, dynamic>>> _loadVariables() async {
    final response = await Supabase.instance.client
        .from('variables')
        .select('id, name, unit, min_value, max_value')
        .eq('decision_id', widget.decision['id'])
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  void _refreshVariables() {
    setState(() {
      _variablesFuture = _loadVariables();
    });
  }

  // AGREGAR VARIABLE
  Future<void> _addVariable() async {
    final values = await _showVariableDialog();

    if (values == null || !mounted) return;

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('Debes iniciar sesión.');
      }

      await Supabase.instance.client.from('variables').insert({
        'decision_id': widget.decision['id'],
        'name': values['name'],
        'unit': values['unit'],
        'min_value': values['min_value'],
        'max_value': values['max_value'],
      });

      if (!mounted) return;

      _refreshVariables();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Variable guardada correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar la variable: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // EDITAR VARIABLE
  Future<void> _editVariable(
    Map<String, dynamic> variable,
  ) async {
    final values = await _showVariableDialog(variable: variable);

    if (values == null || !mounted) return;

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('Debes iniciar sesión.');
      }

      await Supabase.instance.client
          .from('variables')
          .update({
            'name': values['name'],
            'unit': values['unit'],
            'min_value': values['min_value'],
            'max_value': values['max_value'],
          })
          .eq('id', variable['id'])
          .eq('decision_id', widget.decision['id']);

      if (!mounted) return;

      _refreshVariables();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Variable actualizada correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo actualizar la variable: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // FORMULARIO COMPARTIDO PARA AGREGAR Y EDITAR
  Future<Map<String, dynamic>?> _showVariableDialog({
    Map<String, dynamic>? variable,
  }) async {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: variable?['name']?.toString() ?? '',
    );

    final unitController = TextEditingController(
      text: variable?['unit']?.toString() ?? '',
    );

    final minController = TextEditingController(
      text: variable?['min_value']?.toString() ?? '',
    );

    final maxController = TextEditingController(
      text: variable?['max_value']?.toString() ?? '',
    );

    try {
      return await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              variable == null ? 'Agregar variable' : 'Editar variable',
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la variable',
                        hintText: 'Ej. Inversión inicial',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unidad',
                        hintText: 'Ej. pesos, meses, porcentaje',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa la unidad';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: minController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Valor mínimo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el valor mínimo';
                        }

                        if (double.tryParse(value.trim()) == null) {
                          return 'Ingresa un número válido';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: maxController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Valor máximo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el valor máximo';
                        }

                        final max = double.tryParse(value.trim());
                        final min = double.tryParse(minController.text.trim());

                        if (max == null) {
                          return 'Ingresa un número válido';
                        }

                        if (min != null && max < min) {
                          return 'Debe ser mayor o igual al mínimo';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;

                  Navigator.pop(dialogContext, {
                    'name': nameController.text.trim(),
                    'unit': unitController.text.trim(),
                    'min_value': double.parse(minController.text.trim()),
                    'max_value': double.parse(maxController.text.trim()),
                  });
                },
                child: const Text('Guardar cambios'),
              ),
            ],
          );
        },
      );
    } finally {
      nameController.dispose();
      unitController.dispose();
      minController.dispose();
      maxController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final decisionTitle = widget.decision['title'] ?? 'Decisión';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Variables'),
        actions: [
          IconButton(
            tooltip: 'Ver escenarios',
            icon: const Icon(Icons.account_tree_outlined),
            onPressed: () {
              context.push(
                '/decisions/scenarios',
                extra: widget.decision,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addVariable,
        icon: const Icon(Icons.add),
        label: const Text('Agregar variable'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  decisionTitle,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Administra los factores que utilizarás en tus escenarios.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Variables registradas',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _refreshVariables,
                      tooltip: 'Actualizar',
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _variablesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 40,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No se pudieron cargar las variables.',
                              ),
                              Text(
                                '${snapshot.error}',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _refreshVariables,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        );
                      }

                      final variables = snapshot.data ?? [];

                      if (variables.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tune,
                                size: 55,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Todavía no hay variables',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Agrega una variable para esta decisión.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: variables.length,
                        itemBuilder: (context, index) {
                          final variable = variables[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE8EAF6),
                                child: Icon(
                                  Icons.tune,
                                  color: Colors.indigo,
                                ),
                              ),
                              title: Text(
                                variable['name'] ?? 'Sin nombre',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Unidad: ${variable['unit'] ?? '-'}\n'
                                'Mínimo: ${variable['min_value']} | '
                                'Máximo: ${variable['max_value']}',
                              ),
                              trailing: IconButton(
                                tooltip: 'Editar variable',
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.indigo,
                                ),
                                onPressed: () {
                                  _editVariable(variable);
                                },
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      );
                    },
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
