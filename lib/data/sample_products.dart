import '../models/product.dart';

const List<Product> sampleProducts = [
  Product(
    id: 1,
    title: 'Classic Cotton Tee',
    description: 'A soft everyday t-shirt with a clean fit.',
    price: 799.00,
    imageUrl: 'https://picsum.photos/seed/shirt/400/400',
    category: 'clothing',
  ),
  Product(
    id: 2,
    title: 'Wireless Headphones',
    description: 'Comfortable headphones with balanced sound.',
    price: 2999.00,
    imageUrl: 'https://picsum.photos/seed/headphones/400/400',
    category: 'electronics',
  ),
  Product(
    id: 3,
    title: 'Everyday Sneakers',
    description: 'Lightweight sneakers for casual wear.',
    price: 2499.00,
    imageUrl: 'https://picsum.photos/seed/shoes/400/400',
    category: 'footwear',
  ),
  Product(
    id: 4,
    title: 'Minimal Backpack',
    description: 'Simple backpack with space for your daily essentials.',
    price: 1499.00,
    imageUrl: 'https://picsum.photos/seed/bag/400/400',
    category: 'accessories',
  ),
  Product(
    id: 5,
    title: 'Smart Water Bottle',
    description: 'A reusable bottle for daily hydration.',
    price: 699.00,
    imageUrl: 'https://picsum.photos/seed/bottle/400/400',
    category: 'lifestyle',
  ),
  Product(
    id: 6,
    title: 'Desk Lamp',
    description: 'Compact lamp for your study desk.',
    price: 1299.00,
    imageUrl: 'https://picsum.photos/seed/lamp/400/400',
    category: 'home',
  ),
];
