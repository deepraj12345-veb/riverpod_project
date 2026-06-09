import 'package:riverpod_project/core/models/models.dart';

class FakeData {
  static const List<BannerModel> banners = [
    BannerModel(
      id: 'b1',
      title: 'Summer Sale 🔥',
      subtitle: 'Up to 70% OFF on all products',
      imageUrl:
          'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=600',
      bgColor: 'FF6C63FF',
    ),
    BannerModel(
      id: 'b2',
      title: 'New Arrivals 🆕',
      subtitle: 'Fresh styles just dropped',
      imageUrl:
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600',
      bgColor: 'FFFF6584',
    ),
    BannerModel(
      id: 'b3',
      title: 'Exclusive Deals 💎',
      subtitle: 'Members-only offers await',
      imageUrl:
          'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=600',
      bgColor: 'FF43E97B',
    ),
  ];

  static const List<String> categories = [
    'All',
    'Fruits',
    'Vegetables',
    'Groceries',
    'Dairy',
    'Snacks',
  ];

  static const List<ProductModel> products = [
    ProductModel(
      id: 'p1',
      name: 'Fresh Red Apple',
      description:
          'Crisp and sweet fresh red apples. Perfect for a healthy snack or making delicious apple pie.',
      price: 2.99,
      originalPrice: 3.99,
      imageUrl:
          'https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?w=400',
      category: 'Fruits',
      rating: 4.8,
      reviewCount: 1240,
      tags: ['Fresh', 'Organic', 'Sweet'],
      isFavorite: true,
    ),
    ProductModel(
      id: 'p2',
      name: 'Organic Bananas',
      description:
          'Rich in potassium and perfect for energy. A great addition to your morning cereal or smoothie.',
      price: 1.49,
      originalPrice: 1.99,
      imageUrl:
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400',
      category: 'Fruits',
      rating: 4.7,
      reviewCount: 850,
      tags: ['Organic', 'Energy', 'Fresh'],
    ),
    ProductModel(
      id: 'p3',
      name: 'Roma Tomatoes',
      description:
          'Plump and juicy Roma tomatoes. Ideal for salads, sauces, and everyday cooking.',
      price: 1.99,
      originalPrice: 2.49,
      imageUrl:
          'https://prabhaorganics.com/cdn/shop/files/Cherry-tomato2.jpg?v=1730696808',
      category: 'Vegetables',
      rating: 4.6,
      reviewCount: 620,
      tags: ['Fresh', 'Cooking', 'Juicy'],
    ),
    ProductModel(
      id: 'p4',
      name: 'Fresh Broccoli',
      description:
          'Fresh green broccoli florets. High in fiber and vitamins, perfect for steaming or stir-fries.',
      price: 2.49,
      originalPrice: 2.99,
      imageUrl:
          'https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=400',
      category: 'Vegetables',
      rating: 4.5,
      reviewCount: 410,
      tags: ['Fresh', 'Healthy', 'Green'],
      isFavorite: true,
    ),
    ProductModel(
      id: 'p5',
      name: 'Fresh Whole Milk',
      description:
          'Rich and creamy fresh whole milk. A good source of calcium and vitamin D.',
      price: 3.49,
      originalPrice: 3.99,
      imageUrl:
          'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400',
      category: 'Dairy',
      rating: 4.9,
      reviewCount: 1500,
      tags: ['Fresh', 'Dairy', 'Rich'],
    ),
    ProductModel(
      id: 'p6',
      name: 'Whole Wheat Bread',
      description:
          'Soft and nutritious whole wheat bread. Perfect for sandwiches and morning toast.',
      price: 2.99,
      originalPrice: 3.49,
      imageUrl:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
      category: 'Groceries',
      rating: 4.6,
      reviewCount: 780,
      tags: ['Nutritious', 'Whole Wheat', 'Soft'],
    ),
    ProductModel(
      id: 'p7',
      name: 'Farm Fresh Eggs',
      description:
          'A dozen farm fresh large brown eggs. Perfect for baking, breakfast, and cooking.',
      price: 4.99,
      originalPrice: 5.99,
      imageUrl:
          'https://images.unsplash.com/photo-1506976785307-8732e854ad03?w=400',
      category: 'Groceries',
      rating: 4.8,
      reviewCount: 1100,
      tags: ['Farm Fresh', 'Brown Eggs', 'Protein'],
      isFavorite: true,
    ),
    ProductModel(
      id: 'p8',
      name: 'Fresh Oranges',
      description:
          'Juicy and sweet fresh oranges. Packed with Vitamin C, great for fresh juice.',
      price: 3.99,
      originalPrice: 4.99,
      imageUrl:
          'https://images.unsplash.com/photo-1557800636-894a64c1696f?w=400',
      category: 'Fruits',
      rating: 4.7,
      reviewCount: 920,
      tags: ['Juicy', 'Vitamin C', 'Sweet'],
    ),
    ProductModel(
      id: 'p9',
      name: 'Fresh Carrots',
      description:
          'Sweet and crunchy fresh carrots. Great for snacking, cooking, or making carrot juice.',
      price: 1.49,
      originalPrice: 1.99,
      imageUrl:
          'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400',
      category: 'Vegetables',
      rating: 4.6,
      reviewCount: 540,
      tags: ['Fresh', 'Crunchy', 'Sweet'],
    ),
    ProductModel(
      id: 'p10',
      name: 'Cheddar Cheese',
      description:
          'Rich and sharp cheddar cheese block. Perfect for grating, slicing, or melting.',
      price: 4.49,
      originalPrice: 5.49,
      imageUrl:
          'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400',
      category: 'Dairy',
      rating: 4.7,
      reviewCount: 670,
      tags: ['Rich', 'Sharp', 'Dairy'],
    ),
    ProductModel(
      id: 'p11',
      name: 'Potato Chips',
      description:
          'Crispy and salty classic potato chips. The perfect snack for movie nights.',
      price: 1.99,
      originalPrice: 2.49,
      imageUrl:
          'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400',
      category: 'Snacks',
      rating: 4.4,
      reviewCount: 1300,
      tags: ['Crispy', 'Salty', 'Snack'],
    ),
    ProductModel(
      id: 'p12',
      name: 'Chocolate Chip Cookies',
      description:
          'Delicious chocolate chip cookies with a soft center and crispy edges.',
      price: 3.49,
      originalPrice: 3.99,
      imageUrl:
          'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400',
      category: 'Snacks',
      rating: 4.8,
      reviewCount: 1450,
      tags: ['Delicious', 'Sweet', 'Soft'],
      isFavorite: true,
    ),
  ];

  static const UserModel currentUser = UserModel(
    id: 'u1',
    name: 'Alex Johnson',
    email: 'alex.johnson@email.com',
    phone: '+1 (555) 234-5678',
    avatarUrl:
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
    address: '123 Oak Street, San Francisco, CA 94102',
  );
}
