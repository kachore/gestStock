// lib/screens/products/product_list_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/product_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final productProvider = context.read<ProductProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    
    await Future.wait([
      productProvider.loadProducts(),
      categoryProvider.loadCategories(),
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Réinitialiser les filtres
              context.read<ProductProvider>().filterByCategory(null);
              _searchController.clear();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ProductProvider>().searchProducts('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                context.read<ProductProvider>().searchProducts(value);
              },
            ),
          ),

          // Filtres par catégorie
          Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              if (categoryProvider.categories.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categoryProvider.categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Consumer<ProductProvider>(
                        builder: (context, productProvider, child) {
                          return CategoryChip(
                            category: Category(name: 'Tous', id: 0),
                            isSelected: productProvider.selectedCategoryId == null,
                            onTap: () {
                              productProvider.filterByCategory(null);
                            },
                          );
                        },
                      );
                    }

                    final category = categoryProvider.categories[index - 1];
                    return Consumer<ProductProvider>(
                      builder: (context, productProvider, child) {
                        return FutureBuilder<int>(
                          future: categoryProvider.getProductCount(category.id!),
                          builder: (context, snapshot) {
                            return CategoryChip(
                              category: category,
                              isSelected: productProvider.selectedCategoryId == category.id,
                              productCount: snapshot.data,
                              onTap: () {
                                productProvider.filterByCategory(category.id);
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),

          // Liste des produits
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

               if (productProvider.products.isEmpty) {
                  return SingleChildScrollView( // ← Ajouter ceci
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: EmptyState(
                            icon: Icons.inventory_2,
                            message: 'Aucun produit trouvé.\nAjoutez votre premier produit !',
                            buttonText: 'Ajouter un produit',
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, child) {
                      return ListView.builder(
                        itemCount: productProvider.products.length,
                        itemBuilder: (context, index) {
                          final product = productProvider.products[index];
                          final category = categoryProvider.getCategoryById(product.categoryId);

                          return ProductCard(
                            product: product,
                            category: category,
                            onTap: () => _showProductDetails(context, product, category),
                            onEdit: () => _openProductForm(context, product: product),
                            onDelete: () => _deleteProduct(context, product),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProductForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  void _openProductForm(BuildContext context, {Product? product}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: product),
      ),
    );
  }

  void _showProductDetails(BuildContext context, Product product, Category? category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: product.imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(product.imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.inventory_2,
                                  color: AppConstants.primaryColor,
                                  size: 40,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.inventory_2,
                            color: AppConstants.primaryColor,
                            size: 40,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (category != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Prix unitaire', Helpers.formatPrice(product.price)),
              _buildDetailRow('Stock disponible', '${product.quantity} unités'),
              _buildDetailRow('Valeur totale', Helpers.formatPrice(product.price * product.quantity)),
              if (product.supplier != null)
                _buildDetailRow('Fournisseur', product.supplier!),
              _buildDetailRow('Date d\'ajout', Helpers.formatDateFromString(product.createdAt)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openProductForm(context, product: product);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteProduct(context, product);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Supprimer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context, Product product) async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Supprimer le produit',
      message: 'Voulez-vous vraiment supprimer "${product.name}" ?',
      confirmText: 'Supprimer',
    );

    if (confirm && context.mounted) {
      final success = await context.read<ProductProvider>().deleteProduct(product.id!);
      
      if (context.mounted) {
        if (success) {
          Helpers.showSuccessSnackBar(context, AppConstants.msgProductDeleted);
        } else {
          Helpers.showErrorSnackBar(context, AppConstants.msgError);
        }
      }
    }
  }
}