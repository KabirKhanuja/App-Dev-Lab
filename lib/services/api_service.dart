import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/sample_products.dart';
import '../models/product.dart';

class ApiService {
  static const String _endpoint = 'https://fakestoreapi.com/products';

  Future<List<Product>> fetchProducts() async {
    try {
      // LAB 8: HTTP GET request to fetch REST API data
      // We call FakeStore API and wait for the server response
      final response = await http.get(Uri.parse(_endpoint));

      if (response.statusCode != 200) {
        throw Exception('Failed to load products');
      }

      // LAB 8: Basic JSON parsing from response body into Product model objects
      // Raw JSON is converted into strongly typed Product instances for UI use
      final decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // LAB 9: Offline fallback support using local sample data
      // If network fails, the app still works with built-in sample products
      return sampleProducts;
    }
  }
}
