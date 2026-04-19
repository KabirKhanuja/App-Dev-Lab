import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';
import 'product_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();
  final _storageService = StorageService();
  late final Future<List<Product>> _productsFuture;
  final List<Product> _cartItems = [];
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiService.fetchProducts();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    final savedCartCount = await _storageService.getCartCount();
    if (!mounted) {
      return;
    }

    setState(() {
      _cartCount = savedCartCount;
    });
  }

  Future<void> _addToCart(Product product) async {
    setState(() {
      _cartItems.add(product);
      _cartCount++;
    });

    await _storageService.saveCartCount(_cartCount);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${product.title} added to cart')));
  }

  Future<void> _logout() async {
    await _storageService.clearLoginStatus();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            CartScreen(items: List<Product>.unmodifiable(_cartItems)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MiniCart'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
          ),
          Badge(
            isLabelVisible: _cartCount > 0,
            label: Text('$_cartCount'),
            child: IconButton(
              onPressed: _openCart,
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: 'Cart',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load products: ${snapshot.error}'),
            );
          }

          final products = snapshot.data ?? const <Product>[];

          return ProductListScreen(
            products: products,
            onAddToCart: _addToCart,
            onProductTap: (product) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => ProductDetailScreen(
                    product: product,
                    onAddToCart: _addToCart,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
