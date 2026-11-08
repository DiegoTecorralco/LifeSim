
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditDecisionPage extends StatefulWidget {
  final Map<String, dynamic> decision;

  const EditDecisionPage({
    super.key,
    required this.decision,
  });

  @override
  State<EditDecisionPage> createState() =>
      _EditDecisionPageState();
}

class _EditDecisionPageState extends State<EditDecisionPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  String? _selectedCategory;
  bool _isSaving = false;

  final List<String> _categories = [
    'Personal',
    'Educación',
    'Trabajo',
    'Finanzas',
    'Salud',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.decision['title'] ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.decision['description'] ?? '',
    );

    final category = widget.decision['category'];

    _selectedCategory = _categories.contains(category)
        ? category
        : null;
  }

  Future<void> _updateDecision() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para editar una decisión.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await supabase
          .from('decisions')
          .update({
            'title': _titleController.text.trim(),
            'description': _descriptionController.text.trim(),
            'category': _selectedCategory,
          })
          .eq('id', widget.decision['id'])
          .eq('user_id', user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Decisión actualizada correctamente!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } on PostgrestException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de Supabase: ${error.message}'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo actualizar la decisión: $error'),
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
        title: const Text('Editar decisión'),
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
                  Icons.edit_note,
                  size: 55,
                  color: Colors.indigo,
                ),

                const SizedBox(height: 15),

                Text(
                  'Modificar decisión',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Actualiza la información de tu decisión.',
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el título de la decisión';
                    }

                    if (value.trim().length < 3) {
                      return 'El título debe tener al menos 3 caracteres';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Escribe una descripción';
                    }

                    if (value.trim().length < 10) {
                      return 'Escribe al menos 10 caracteres';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category_outlined),
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

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _updateDecision,
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
                      _isSaving ? 'Guardando...' : 'Guardar cambios',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
