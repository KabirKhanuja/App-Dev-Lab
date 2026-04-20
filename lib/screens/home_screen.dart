import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
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
  final _firestoreService = FirestoreService();
  // LAB 8: api data source is consumed on the home screen
  // so products are loaded from the internet and then shown in the list ui
  late final Future<List<Product>> _productsFuture;
  StreamSubscription<int>? _cartCountSubscription;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiService.fetchProducts();
    _watchCartCount();
  }

  @override
  void dispose() {
    _cartCountSubscription?.cancel();
    super.dispose();
  }

  void _watchCartCount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    _cartCountSubscription = _firestoreService.cartCountStream(user.uid).listen((
      count,
    ) {
      if (!mounted) {
        return;
      }

      // LAB 6: setState updates UI when local state changes
      // whenever cart data changes in Firestore, badge count updates instantly
      setState(() {
        _cartCount = count;
      });
    });
  }

  Future<String?> _requireUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please login again.')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
    return null;
  }

  Future<void> _addToCart(Product product) async {
    final userId = await _requireUserId();
    if (userId == null) {
      return;
    }

    // LAB 6: Stateful interaction and remote state update
    // add-to-cart writes into Firestore so cart persists per user account
    await _firestoreService.addToCart(uid: userId, product: product);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${product.title} added to cart')));
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _openCart() async {
    final userId = await _requireUserId();
    if (userId == null) {
      return;
    }

    final cartItems = await _firestoreService.getCartItems(userId);

    if (!mounted) {
      return;
    }

    // LAB 5: Navigator.push to move between screens
    // This creates a new route and opens the cart page on top
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // LAB 5: Passing data between screens
        // The cart screen receives current items so it can render totals and rows
        builder: (context) => CartScreen(items: cartItems),
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
