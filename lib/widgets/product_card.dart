// lib/widgets/product_card.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Category? category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    Key? key,
    required this.product,
    this.category,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image ou icône
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: product.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          product.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.inventory_2,
                              color: AppConstants.primaryColor,
                              size: 30,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.inventory_2,
                        color: AppConstants.primaryColor,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 16),
              
              // Informations produit
              Expanded(
                child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(product.name,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold)),
    const SizedBox(height: 6),
    if (category != null)
      Text('Catégorie : ${category!.name}',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
    const SizedBox(height: 8),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: product.isLowStock
            ? AppConstants.errorColor.withOpacity(0.12)
            : AppConstants.successColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            product.isLowStock ? Icons.warning : Icons.check_circle,
            size: 14,
            color: product.isLowStock
                ? AppConstants.errorColor
                : AppConstants.successColor,
          ),
          const SizedBox(width: 4),
          Text(
            'Stock : ${product.quantity}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: product.isLowStock
                  ? AppConstants.errorColor
                  : AppConstants.successColor,
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 6),
    Text(
      Helpers.formatPrice(product.price),
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryColor),
    ),
  ],
),
              ),

              
              // Actions
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 12),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
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
}