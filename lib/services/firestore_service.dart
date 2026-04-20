import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> upsertUserProfile({required User user, String? name}) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    await userDoc.set({
      'email': user.email,
      'name': (name == null || name.trim().isEmpty)
          ? (user.email?.split('@').first ?? 'User')
          : name.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<int> cartCountStream(String uid) {
    return _firestore.collection('carts').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) {
        return 0;
      }

      final items = (data['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList();

      return items.fold<int>(0, (sum, item) {
        final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
        return sum + quantity;
      });
    });
  }

  Future<List<Product>> getCartItems(String uid) async {
    final cartDoc = await _firestore.collection('carts').doc(uid).get();
    final data = cartDoc.data();
    if (data == null) {
      return <Product>[];
    }

    final items = (data['items'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();

    final products = <Product>[];

    for (final item in items) {
      final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
      final product = Product(
        id: (item['id'] as num?)?.toInt() ?? 0,
        title: item['title'] as String? ?? 'Untitled product',
        description: item['description'] as String? ?? '',
        price: (item['price'] as num?)?.toDouble() ?? 0,
        imageUrl: item['imageUrl'] as String? ?? '',
        category: item['category'] as String? ?? 'general',
      );

      for (var i = 0; i < quantity; i++) {
        products.add(product);
      }
    }

    return products;
  }

  Future<void> addToCart({
    required String uid,
    required Product product,
  }) async {
    final cartRef = _firestore.collection('carts').doc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(cartRef);
      final data = snapshot.data() ?? <String, dynamic>{};

      final items = (data['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final itemIndex = items.indexWhere(
        (item) => (item['id'] as num?)?.toInt() == product.id,
      );

      if (itemIndex == -1) {
        items.add({
          'id': product.id,
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'category': product.category,
          'quantity': 1,
        });
      } else {
        final quantity = (items[itemIndex]['quantity'] as num?)?.toInt() ?? 0;
        items[itemIndex]['quantity'] = quantity + 1;
      }

      transaction.set(cartRef, {'items': items}, SetOptions(merge: true));
    });
  }
}
