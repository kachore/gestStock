// lib/screens/categories/category_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({Key? key, this.category}) : super(key: key);

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isLoading = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    
    if (_isEditing) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la catégorie' : 'Nouvelle catégorie'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icône de catégorie
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppConstants.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.category,
                      size: 50,
                      color: AppConstants.accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Nom de la catégorie
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la catégorie',
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: Helpers.validateName,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optionnel)',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Bouton de soumission
                CustomButton(
                  text: _isEditing ? 'Modifier' : 'Ajouter',
                  icon: _isEditing ? Icons.edit : Icons.add,
                  onPressed: _submitForm,
                  isLoading: _isLoading,
                ),
                
                if (_isEditing) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Annuler'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final category = Category(
      id: _isEditing ? widget.category!.id : null,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    final categoryProvider = context.read<CategoryProvider>();
    final success = _isEditing
        ? await categoryProvider.updateCategory(category)
        : await categoryProvider.addCategory(category);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Helpers.showSuccessSnackBar(
          context,
          _isEditing ? 'Catégorie modifiée' : AppConstants.msgCategoryAdded,
        );
        Navigator.pop(context);
      } else {
        Helpers.showErrorSnackBar(context, AppConstants.msgError);
      }
    }
  }
}