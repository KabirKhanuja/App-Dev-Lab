import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({
    super.key,
    required this.products,
    required this.onAddToCart,
    required this.onProductTap,
  });

  final List<Product> products;
  final ValueChanged<Product> onAddToCart;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('No products available.'));
    }

    // LAB 7: Dynamic content rendering with ListView
    // The list builds only visible items, so it scales better for more products
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];

        // LAB 7: Each item is presented as a Card widget
        // Cards make each product block clear and easy to scan in the UI
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onProductTap(product),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      product.imageUrl,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 88,
                        height: 88,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // LAB 3: Expanded helps responsive layout in a Row
                  // It lets text take remaining space without overflowing image area
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.category,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => onProductTap(product),
                              child: const Text('Details'),
                            ),
                            const Spacer(),
                            FilledButton.tonalIcon(
                              onPressed: () => onAddToCart(product),
                              icon: const Icon(
                                Icons.add_shopping_cart_outlined,
                              ),
                              label: const Text('Add'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
