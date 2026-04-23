import 'dart:collection';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import 'product_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.isDarkModeEnabled,
    required this.onThemeModeChanged,
  });

  final bool isDarkModeEnabled;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();
  final _storageService = StorageService();
  final _searchController = TextEditingController();
  // LAB 8: api data source is consumed on the home screen
  // so products are loaded from the internet and then shown in the list ui
  late final Future<List<Product>> _productsFuture;
  final List<Product> _cartItems = [];
  int _cartCount = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiService.fetchProducts();
    _loadCartCount();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // We map each normalized word token to product indexes so search can find
  // matching products quickly by token-prefix lookup.
  HashMap<String, List<int>> _buildSearchIndex(List<Product> products) {
    final index = HashMap<String, List<int>>();

    for (var i = 0; i < products.length; i++) {
      final product = products[i];
      final searchable = '${product.title} ${product.category}'.toLowerCase();
      final tokens = searchable
          .split(RegExp(r'[^a-z0-9]+'))
          .where((token) => token.isNotEmpty)
          .toSet();

      for (final token in tokens) {
        index.putIfAbsent(token, () => <int>[]).add(i);
      }
    }

    return index;
  }

  List<Product> _searchProducts(
    List<Product> products,
    HashMap<String, List<int>> index,
    String query,
  ) {
    // For multi-word input, we keep only products present in all term matches,
    // which gives accurate narrowing (for example "wireless head" -> headphones)
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return products;
    }

    final terms = normalized
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList();
    if (terms.isEmpty) {
      return products;
    }

    Set<int>? result;

    for (final term in terms) {
      final matchesForTerm = <int>{};

      index.forEach((token, positions) {
        if (token.startsWith(term)) {
          matchesForTerm.addAll(positions);
        }
      });

      if (result == null) {
        result = matchesForTerm;
      } else {
        result = result.intersection(matchesForTerm);
      }

      if (result.isEmpty) {
        break;
      }
    }

    final sortedIndexes = (result ?? <int>{}).toList()..sort();
    return sortedIndexes.map((i) => products[i]).toList();
  }

  Future<void> _loadCartCount() async {
    final savedCartCount = await _storageService.getCartCount();
    final correctedCartCount = _cartItems.isEmpty ? 0 : savedCartCount;

    if (correctedCartCount != savedCartCount) {
      await _storageService.saveCartCount(correctedCartCount);
    }

    if (!mounted) {
      return;
    }

    // LAB 6: setState updates UI when local state changes
    // whenever saved values are loaded, the badge updates instantly on screen
    setState(() {
      _cartCount = correctedCartCount;
    });
  }

  Future<void> _addToCart(Product product) async {
    // LAB 6: Stateful interaction and remote state update
    // add-to-cart updates local state and persists cart count on device
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

  Future<void> _removeSingleFromCart(Product product) async {
    final index = _cartItems.indexWhere((item) => item.id == product.id);
    if (index == -1) {
      return;
    }

    setState(() {
      _cartItems.removeAt(index);
      _cartCount = _cartItems.length;
    });

    await _storageService.saveCartCount(_cartCount);
  }

  Future<void> _clearCart() async {
    setState(() {
      _cartItems.clear();
      _cartCount = 0;
    });

    await _storageService.saveCartCount(0);
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SettingsScreen(
          isDarkModeEnabled: widget.isDarkModeEnabled,
          onThemeModeChanged: widget.onThemeModeChanged,
        ),
      ),
    );
  }

  Future<void> _openCart() async {
    if (_cartItems.isEmpty && _cartCount != 0) {
      setState(() {
        _cartCount = 0;
      });
      await _storageService.saveCartCount(0);
    }

    // LAB 5: Navigator.push to move between screens
    // This creates a new route and opens the cart page on top
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // LAB 5: Passing data between screens
        // The cart screen receives current items so it can render totals and rows
        builder: (context) => CartScreen(
          items: _cartItems,
          onRemoveItem: _removeSingleFromCart,
          onClearCart: _clearCart,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/app-logo.png', width: 28, height: 28),
            const SizedBox(width: 10),
            const Text('MiniCart'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
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
          // Built HashMap index from product tokens before filtering.
          // This keeps the search implementation structured and easy to explain.
          final searchIndex = _buildSearchIndex(products);
          final filteredProducts = _searchProducts(
            products,
            searchIndex,
            _searchQuery,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
              ),
              Expanded(
                child: ProductListScreen(
                  products: filteredProducts,
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
