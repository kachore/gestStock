// lib/screens/sales/sale_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/sale.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';

class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({Key? key}) : super(key: key);

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  
  Product? _selectedProduct;
  bool _isLoading = false;
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadProducts(); // <--- plus jamais de notifyListeners() pendant le build
  });
    _quantityController.addListener(_calculateTotal);
  }

  Future<void> _loadProducts() async {
    await context.read<ProductProvider>().loadProducts();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_selectedProduct != null) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      setState(() {
        _totalPrice = _selectedProduct!.price * quantity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle vente'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun produit disponible',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ajoutez des produits avant de créer une vente',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      DefaultTabController.of(context).animateTo(1);
                    },
                    child: const Text('Aller aux produits'),
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
                    // Icône
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppConstants.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.shopping_cart,
                          size: 50,
                          color: AppConstants.successColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sélection du produit
                    DropdownButtonFormField<Product>(
                      value: _selectedProduct,
                      decoration: const InputDecoration(
                        labelText: 'Produit',
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      items: provider.products.map((product) {
                        return DropdownMenuItem(
                          value: product,
                          child: Row(
                            children: [
                              Expanded(child: Text(product.name)),
                              Text(
                                'Stock: ${product.quantity}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: product.isLowStock
                                      ? AppConstants.errorColor
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProduct = value;
                          _calculateTotal();
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un produit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Affichage du stock disponible
                    if (_selectedProduct != null) ...[
                      Card(
                        color: _selectedProduct!.isLowStock
                            ? AppConstants.warningColor.withOpacity(0.1)
                            : AppConstants.successColor.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                _selectedProduct!.isLowStock
                                    ? Icons.warning
                                    : Icons.check_circle,
                                color: _selectedProduct!.isLowStock
                                    ? AppConstants.warningColor
                                    : AppConstants.successColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Stock disponible : ${_selectedProduct!.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Prix unitaire : ${Helpers.formatPrice(_selectedProduct!.price)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Quantité
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantité à vendre',
                        prefixIcon: Icon(Icons.shopping_basket),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (Helpers.isNullOrEmpty(value)) {
                          return 'La quantité est requise';
                        }
                        final quantity = int.tryParse(value!);
                        if (quantity == null || quantity <= 0) {
                          return 'Quantité invalide';
                        }
                        if (_selectedProduct != null && quantity > _selectedProduct!.quantity) {
                          return 'Stock insuffisant (${_selectedProduct!.quantity} disponible)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Total
                    if (_totalPrice > 0) ...[
                      Card(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                'Total à payer',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Helpers.formatPrice(_totalPrice),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Bouton de soumission
                    CustomButton(
                      text: 'Valider la vente',
                      icon: Icons.check,
                      onPressed: _submitForm,
                      isLoading: _isLoading,
                      backgroundColor: AppConstants.successColor,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Annuler'),
                    ),
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

    final quantity = int.parse(_quantityController.text);
    final sale = Sale(
      productId: _selectedProduct!.id!,
      productName: _selectedProduct!.name,
      quantity: quantity,
      unitPrice: _selectedProduct!.price,
      totalPrice: _totalPrice,
    );

    final saleProvider = context.read<SaleProvider>();
    final success = await saleProvider.createSale(sale);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        // Recharger les produits pour mettre à jour le stock
        await context.read<ProductProvider>().loadProducts();
        
        Helpers.showSuccessSnackBar(context, AppConstants.msgSaleCompleted);
        Navigator.pop(context);
      } else {
        Helpers.showErrorSnackBar(
          context,
          saleProvider.error ?? AppConstants.msgInsufficientStock,
        );
      }
    }
  }
}