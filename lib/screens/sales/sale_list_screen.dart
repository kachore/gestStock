// lib/screens/sales/sale_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sale_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/sale_card.dart';
import '../../widgets/empty_state.dart';
import 'sale_form_screen.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({Key? key}) : super(key: key);

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
     WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadData(); // <--- plus jamais de notifyListeners() pendant le build
  });
  }

  Future<void> _loadData() async {
    await context.read<SaleProvider>().loadSales();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventes'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Historique'),
            Tab(text: 'Statistiques'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryTab(),
          _buildStatsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSaleForm(context),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Nouvelle vente'),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<SaleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.sales.isEmpty) {
          return EmptyState(
            icon: Icons.receipt_long,
            message: 'Aucune vente enregistrée.\nCommencez à vendre !',
            buttonText: 'Nouvelle vente',
            onButtonPressed: () => _openSaleForm(context),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: provider.sales.length,
            itemBuilder: (context, index) {
              final sale = provider.sales[index];
              return SaleCard(
                sale: sale,
                onDelete: () => _deleteSale(context, sale.id!),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return Consumer<SaleProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<Map<String, dynamic>>(
          future: provider.getTodayStats(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final todayCount = snapshot.data!['todayCount'] as int;
            final todayTotal = snapshot.data!['todayTotal'] as double;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card ventes du jour
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.today,
                            size: 48,
                            color: AppConstants.primaryColor,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Ventes du jour',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '$todayCount',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Transaction${todayCount > 1 ? "s" : ""}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.grey.shade300,
                              ),
                              Column(
                                children: [
                                  Text(
                                    Helpers.formatPrice(todayTotal),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.successColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Total général
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.assessment,
                            size: 48,
                            color: AppConstants.accentColor,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Statistiques générales',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildStatRow(
                            'Nombre total de ventes',
                            '${provider.sales.length}',
                          ),
                          const Divider(height: 24),
                          _buildStatRow(
                            'Revenu total',
                            Helpers.formatPrice(
                              provider.sales.fold(0, (sum, sale) => sum + sale.totalPrice),
                            ),
                          ),
                          const Divider(height: 24),
                          _buildStatRow(
                            'Panier moyen',
                            provider.sales.isEmpty
                                ? '0 ${AppConstants.currency}'
                                : Helpers.formatPrice(
                                    provider.sales.fold(0.0, (sum, sale) => sum + sale.totalPrice) /
                                        provider.sales.length,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Card(
                      color: AppConstants.cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppConstants.accentColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Les statistiques sont calculées en temps réel à partir de vos ventes.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppConstants.textColor,
          ),
        ),
      ],
    );
  }

  void _openSaleForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SaleFormScreen(),
      ),
    );
  }

  Future<void> _deleteSale(BuildContext context, int saleId) async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Supprimer la vente',
      message: 'Attention : Le stock ne sera pas restauré.\nContinuer ?',
      confirmText: 'Supprimer',
    );

    if (confirm && context.mounted) {
      final success = await context.read<SaleProvider>().deleteSale(saleId);
      
      if (context.mounted) {
        if (success) {
          Helpers.showSuccessSnackBar(context, 'Vente supprimée');
        } else {
          Helpers.showErrorSnackBar(context, AppConstants.msgError);
        }
      }
    }
  }
}