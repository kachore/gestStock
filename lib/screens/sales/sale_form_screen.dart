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
  final _customerController = TextEditingController(); // Nouveau champ
  
  Product? _selectedProduct;
  bool _isLoading = false;
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _quantityController.addListener(_calculateTotal);
  }

  Future<void> _loadProducts() async {
    await context.read<ProductProvider>().loadProducts();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _customerController.dispose();
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
                   DropdownButtonFormField<int>( // Changez le type en int
                        value: _selectedProduct?.id, // Utilisez l'ID comme valeur
                        decoration: InputDecoration(
                          labelText: 'Produit',
                          prefixIcon: Icon(Icons.inventory_2),
                        ),
                        items: provider.products.map((product) {
                          return DropdownMenuItem<int>( // Spécifiez le type int
                            value: product.id, // Utilisez l'ID comme valeur
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(product.name),
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
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (int? value) {
                          setState(() {
                            // Trouvez le produit correspondant à l'ID
                            _selectedProduct = provider.products.firstWhere(
                              (product) => product.id == value,
                              // orElse: () => null, // Si vous autorisez la valeur null
                            );
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
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: _selectedProduct!.isLowStock
                              ? AppConstants.warningColor
                              : AppConstants.cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Icône avec fond arrondi
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _selectedProduct!.isLowStock
                                        ? AppConstants.cardColor
                                        : AppConstants.cardColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _selectedProduct!.isLowStock
                                        ? Icons.warning_amber_rounded
                                        : Icons.inventory_2_rounded,
                                    color: _selectedProduct!.isLowStock
                                        ? AppConstants.warningColor
                                        : AppConstants.successColor,
                                    size: 20,
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Contenu texte
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_selectedProduct!.quantity} en stock',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 4),
                                      
                                      Text(
                                        "Unité : ${Helpers.formatPrice(_selectedProduct!.price)}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      
                                      // Barre de progression optionnelle pour le stock
                                      if (_selectedProduct!.isLowStock) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: AppConstants.warningColor.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: _selectedProduct!.quantity / 10, // Ajustez selon votre logique
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppConstants.warningColor,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                
                                // Badge de statut optionnel
                                if (_selectedProduct!.isLowStock)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppConstants.warningColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Stock faible',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                    const SizedBox(height: 16),

                    // Info client (optionnel)
                    TextFormField(
                      controller: _customerController,
                      decoration: const InputDecoration(
                        labelText: 'Info client (optionnel)',
                        prefixIcon: Icon(Icons.person),
                        hintText: 'Nom ou numéro du client',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Total
                    if (_totalPrice > 0) ...[
                     Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadowColor: AppConstants.primaryColor.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                ),
                                
                                const SizedBox(height: 10),
                                
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      AppConstants.primaryColor,
                                      AppConstants.primaryColor.withOpacity(0.8),
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    Helpers.formatPrice(_totalPrice),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // La couleur réelle vient du shader
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 6),
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
      customerInfo: _customerController.text.trim().isEmpty 
          ? null 
          : _customerController.text.trim(),
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