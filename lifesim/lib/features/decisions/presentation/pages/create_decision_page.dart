
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateDecisionPage extends StatefulWidget {
  const CreateDecisionPage({super.key});

  @override
  State<CreateDecisionPage> createState() => _CreateDecisionPageState();
}

class _CreateDecisionPageState extends State<CreateDecisionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  String? _selectedCategory;
  String? _selectedHorizon;

  bool _isSaving = false;

  final List<String> _categories = [
    'Personal',
    'Educación',
    'Trabajo',
    'Finanzas',
    'Salud',
    'Otros',
  ];

  final List<String> _horizons = [
    'Corto plazo',
    'Mediano plazo',
    'Largo plazo',
  ];

  // Guardar decisión en Supabase
  Future<void> _saveDecision() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes iniciar sesión para crear una decisión.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await supabase.from('decisions').insert({
        'user_id': user.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Decisión creada correctamente!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } on PostgrestException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error de Supabase: ${error.message}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo crear la decisión: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear decisión'),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.psychology_alt_outlined,
                  size: 55,
                ),

                const SizedBox(height: 15),

                Text(
                  'Nueva decisión',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Registra una decisión para analizar '
                  'diferentes posibilidades.',
                ),

                const SizedBox(height: 30),

                // Título
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Ej. Elegir una carrera universitaria',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization:
                      TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Ingresa el título de la decisión';
                    }

                    if (value.trim().length < 3) {
                      return 'El título debe tener al menos 3 caracteres';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Descripción
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText:
                        'Explica qué quieres decidir y por qué...',
                    prefixIcon:
                        Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization:
                      TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Escribe una descripción';
                    }

                    if (value.trim().length < 10) {
                      return 'Escribe al menos 10 caracteres';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Categoría
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon:
                        Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona una categoría';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Horizonte temporal
                DropdownButtonFormField<String>(
                  initialValue: _selectedHorizon,
                  decoration: const InputDecoration(
                    labelText: 'Horizonte temporal',
                    prefixIcon: Icon(Icons.schedule),
                    border: OutlineInputBorder(),
                  ),
                  items: _horizons.map((horizon) {
                    return DropdownMenuItem<String>(
                      value: horizon,
                      child: Text(horizon),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedHorizon = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona un horizonte temporal';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        _isSaving ? null : _saveDecision,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _isSaving
                          ? 'Guardando...'
                          : 'Guardar decisión',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
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
