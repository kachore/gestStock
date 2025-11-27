// lib/screens/products/product_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({Key? key, this.product}) : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  
  int? _selectedCategoryId;
  bool _isLoading = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    
    if (_isEditing) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.quantity.toString();
      _selectedCategoryId = widget.product!.categoryId;
    }
  }

  Future<void> _loadCategories() async {
    await context.read<CategoryProvider>().loadCategories();
    
    // Sélectionner la première catégorie par défaut si aucune n'est sélectionnée
    if (!_isEditing && _selectedCategoryId == null && mounted) {
      final categories = context.read<CategoryProvider>().categories;
      if (categories.isNotEmpty) {
        setState(() {
          _selectedCategoryId = categories.first.id;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le produit' : 'Nouveau produit'),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.category,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Vous devez d\'abord créer une catégorie',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigation vers catégories
                      DefaultTabController.of(context).animateTo(2);
                    },
                    child: const Text('Aller aux catégories'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icône du produit
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.inventory_2,
                          size: 50,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Nom du produit
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du produit',
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                      validator: Helpers.validateName,
                    ),
                    const SizedBox(height: 16),

                    // Catégorie
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: categoryProvider.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner une catégorie';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Prix
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Prix unitaire (${AppConstants.currency})',
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: Helpers.validatePrice,
                    ),
                    const SizedBox(height: 16),

                    // Quantité
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantité en stock',
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      keyboardType: TextInputType.number,
                      validator: Helpers.validateQuantity,
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
          );
        },
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final product = Product(
      id: _isEditing ? widget.product!.id : null,
      name: _nameController.text.trim(),
      categoryId: _selectedCategoryId!,
      price: double.parse(_priceController.text),
      quantity: int.parse(_quantityController.text),
      createdAt: _isEditing ? widget.product!.createdAt : null,
    );

    final productProvider = context.read<ProductProvider>();
    final success = _isEditing
        ? await productProvider.updateProduct(product)
        : await productProvider.addProduct(product);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Helpers.showSuccessSnackBar(
          context,
          _isEditing ? AppConstants.msgProductUpdated : AppConstants.msgProductAdded,
        );
        Navigator.pop(context);
      } else {
        Helpers.showErrorSnackBar(context, AppConstants.msgError);
      }
    }
  }
}