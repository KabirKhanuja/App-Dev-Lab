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
  // LAB 8: api data source is consumed on the home screen
  // so products are loaded from the internet and then shown in the list ui
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

    // LAB 6: setState updates UI when local state changes
    // whenever these saved values are loaded, the badge updates instantly on screen
    setState(() {
      _cartCount = savedCartCount;
    });
  }

  Future<void> _addToCart(Product product) async {
    // LAB 6: StatefulWidget + setState for interactive cart updates
    // every add action changes the in memory state and then refreshes the visible count
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
    // LAB 5: Navigator.push to move between screens
    // This creates a new route and opens the cart page on top
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // LAB 5: Passing data between screens
        // The cart screen receives current items so it can render totals and rows
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
              // LAB 5: Multi page navigation to product details
              // Tapping an item takes the user to a separate detail view
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => ProductDetailScreen(
                    // LAB 5: Passing selected product to detail screen
                    // The selected product object is sent directly to the next page
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
