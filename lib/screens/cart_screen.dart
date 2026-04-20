import 'package:flutter/material.dart';

import '../models/product.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
    required this.items,
    required this.onRemoveItem,
    required this.onClearCart,
  });

  final List<Product> items;
  final Future<void> Function(Product product) onRemoveItem;
  final Future<void> Function() onClearCart;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<void> _removeItem(Product product) async {
    await widget.onRemoveItem(product);
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _clearAllItems() async {
    await widget.onClearCart();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final total = items.fold<double>(0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              onPressed: _clearAllItems,
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear cart',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                if (index == items.length) {
                  return Card(
                    child: ListTile(
                      title: const Text('Total'),
                      trailing: Text('\$${total.toStringAsFixed(2)}'),
                    ),
                  );
                }

                final product = items[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 56,
                                height: 56,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                ),
                              ),
                        ),
                      ),
                      title: Text(product.title),
                      subtitle: Text(product.category),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('\$${product.price.toStringAsFixed(2)}'),
                          IconButton(
                            onPressed: () => _removeItem(product),
                            icon: const Icon(Icons.remove_circle_outline),
                            tooltip: 'Remove one',
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
}
