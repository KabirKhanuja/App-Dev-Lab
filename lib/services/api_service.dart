import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/sample_products.dart';
import '../models/product.dart';

class ApiService {
  static const String _endpoint = 'https://fakestoreapi.com/products';

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(_endpoint));

      if (response.statusCode != 200) {
        throw Exception('Failed to load products');
      }

      final decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return sampleProducts;
    }
  }
}
