// lib/screens/home/home_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
// import '../../models/sale.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/sale_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
 void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadData();
  });
}

  Future<void> _loadData() async {
    final productProvider = context.read<ProductProvider>();
    final saleProvider = context.read<SaleProvider>();
    
    await Future.wait([
      productProvider.loadProducts(),
      saleProvider.loadTodaySales(),
    ]);
  }

String? _imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                decoration: const BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tableau de bord',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatDate(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Statistiques principales
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStockCard(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSalesCard(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Alertes stock bas
              _buildLowStockSection(),
              
              const SizedBox(height: 24),
              
              // Dernières ventes
              _buildRecentSalesSection(),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockCard() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<Map<String, dynamic>>(
          future: Future.wait([
            provider.getTotalProductCount(),
            provider.getTotalStockValue(),
          ]).then((results) => {
            'count': results[0],
            'value': results[1],
          }),
          builder: (context, snapshot) {
            final count = snapshot.data?['count'] ?? 0;
            final value = snapshot.data?['value'] ?? 0.0;
            
            return DashboardCard(
              title: 'Stock total',
              value: '$count',
              subtitle: Helpers.formatPrice(value),
              icon: Icons.inventory_2,
              color: AppConstants.primaryColor,
            );
          },
        );
      },
    );
  }

  Widget _buildSalesCard() {
    return Consumer<SaleProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<Map<String, dynamic>>(
          future: provider.getTodayStats(),
          builder: (context, snapshot) {
            final count = snapshot.data?['todayCount'] ?? 0;
            final total = snapshot.data?['todayTotal'] ?? 0.0;
            
            return DashboardCard(
              title: 'Ventes du jour',
              value: '$count',
              subtitle: Helpers.formatPrice(total),
              icon: Icons.shopping_cart,
              color: AppConstants.successColor,
            );
          },
        );
      },
    );
  }

  Widget _buildLowStockSection() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<Product>>(
          future: provider.getLowStockProducts(),
          builder: (context, snapshot) {
            final lowStockProducts = snapshot.data ?? [];
            
            if (lowStockProducts.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning,
                        color: AppConstants.warningColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Alertes stock bas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: lowStockProducts.length,
                    itemBuilder: (context, index) {
                      final product = lowStockProducts[index];
                      return _buildLowStockCard(product);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLowStockCard(Product product) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:_imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    File(_imagePath!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.inventory_2,
                                  color: AppConstants.errorColor,
                                  size: 30,
                                ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stock : ${product.quantity}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    Helpers.formatPrice(product.price),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSalesSection() {
    return Consumer<SaleProvider>(
      builder: (context, provider, child) {
        final sales = provider.sales.take(5).toList();
        
        if (sales.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aucune vente aujourd\'hui',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dernières ventes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigation vers la page ventes
                      DefaultTabController.of(context).animateTo(3);
                    },
                    child: const Text('Voir tout'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sales.length,
              itemBuilder: (context, index) {
                return SaleCard(sale: sales[index]);
              },
            ),
          ],
        );
      },
    );
  }
}