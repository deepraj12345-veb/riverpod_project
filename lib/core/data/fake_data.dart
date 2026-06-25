import 'package:veggie_mart/features/home/domain/entities/product_entity.dart';
import 'package:veggie_mart/features/auth/domain/entities/user_entity.dart';
import 'package:veggie_mart/core/models/models.dart';

class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String bgColor;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.bgColor,
  });
}

class FakeData {
  static const List<AddressModel> addresses = [
    AddressModel(
      id: 'addr_1',
      title: 'Home',
      fullAddress: 'Flat 402, Green Valley Apartments, MG Road, Bangalore 560001',
      isDefault: true,
    ),
    AddressModel(
      id: 'addr_2',
      title: 'Work',
      fullAddress: 'Tech Park, Tower B, Electronic City Phase 1, Bangalore 560100',
    ),
    AddressModel(
      id: 'addr_3',
      title: 'Other',
      fullAddress: '15th Cross, 4th Sector, HSR Layout, Bangalore 560102',
    ),
  ];

  static const List<String> paymentMethods = [
    'UPI (Google Pay, PhonePe, Paytm)',
    'Credit / Debit Card',
    'Cash on Delivery (COD)',
    'Net Banking',
  ];

  static const List<BannerModel> banners = [
    BannerModel(
      id: 'b1',
      title: 'Fresh Arrivals',
      subtitle: 'Up to 30% OFF on seasonal vegetables',
      imageUrl:
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600',
      bgColor: 'FF16A34A',
    ),
    BannerModel(
      id: 'b2',
      title: 'Organic Fruits',
      subtitle: 'Farm fresh, delivered to your door',
      imageUrl:
          'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=600',
      bgColor: 'FF059669',
    ),
    BannerModel(
      id: 'b3',
      title: 'Free Delivery',
      subtitle: 'On all orders above Rs 199',
      imageUrl:
          'https://images.unsplash.com/photo-1543168256-418811576931?w=600',
      bgColor: 'FF166534',
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

  static const Map<String, List<String>> subcategories = {
    'All': [
      'Organic',
      'On Sale',
      'Fresh Today',
      'Local Farms',
      'Superfoods',
      'Bestsellers',
      'New Arrivals',
      'Premium',
    ],
    'Fruits': ['Berries & Other', 'Tropical Fruits'],
    'Vegetables': ['Roots, Herbs & Other', 'Basic Vegetables'],
    'Groceries': [
      'Atta, Rice, Dal & More',
      'Cold Drink, Energy Drinks & Juice',
      'Tea, Coffee, Milk Drinks',
      'Dairy Product, Cheese & Eggs',
      'Pharma & Wellness',
      'Snacks, Munchies, Ice-Creams & Sweets',
      'Breakfast & Instant Food',
      'Bakery, Biscuit & Baking Product',
      'Masala, Oil & More',
      'Baby Care',
      'Cleaning Essentials',
      'Home, Office & Stationary',
      'Personal Care',
      'Pet Care',
      'Mouth Fresheners & Candy',
      'Frozen Chicken, Meat & Fish',
      'Pickles, Sauces & Spreads',
      'Dry Fruits, Nuts & Seeds',
      'Papad, Fryums & More',
      'Gifts',
      'Electronics',
    ],
    'Dairy': ['Milk', 'Cheese', 'Curd & Yoghurt', 'Butter & Cream'],
    'Snacks': ['Chips', 'Cookies', 'Nuts & Dry Fruits', 'Chocolates'],
  };

  static const List<ProductEntity> products = [
    ProductEntity(
      id: 'p1',
      name: 'Fresh Red Apple',
      description:
          'Crisp and sweet fresh red apples. Perfect for a healthy snack or making delicious apple pie. Rich in antioxidants and fibre.',
      price: 89,
      originalPrice: 119,
      imageUrl:
          'https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?w=400',
      category: 'Fruits',
      rating: 4.8,
      reviewCount: 1240,
      tags: ['Fresh', 'Organic', 'Sweet'],
      isFavorite: true,
      unit: '500g',
    ),
    ProductEntity(
      id: 'p2',
      name: 'Organic Bananas',
      description:
          'Rich in potassium and perfect for energy. A great addition to your morning cereal or smoothie. Naturally ripened on the farm.',
      price: 49,
      originalPrice: 79,
      imageUrl:
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400',
      category: 'Fruits',
      rating: 4.7,
      reviewCount: 850,
      tags: ['Organic', 'Energy', 'Fresh'],
      unit: '1 kg',
    ),
    ProductEntity(
      id: 'p3',
      name: 'Cherry Tomatoes',
      description:
          'Plump and juicy cherry tomatoes. Ideal for salads, sauces, and everyday cooking. Handpicked for the best quality.',
      price: 64,
      originalPrice: 80,
      imageUrl:
          'https://prabhaorganics.com/cdn/shop/files/Cherry-tomato2.jpg?v=1730696808',
      category: 'Vegetables',
      rating: 4.6,
      reviewCount: 620,
      tags: ['Fresh', 'Cooking', 'Juicy'],
      unit: '250g',
    ),
    ProductEntity(
      id: 'p4',
      name: 'Fresh Broccoli',
      description:
          'Fresh green broccoli florets. High in fibre and vitamins, perfect for steaming or stir-fries. A superfood for your family.',
      price: 69,
      originalPrice: 99,
      imageUrl:
          'https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=400',
      category: 'Vegetables',
      rating: 4.5,
      reviewCount: 410,
      tags: ['Fresh', 'Healthy', 'Green'],
      isFavorite: true,
      inStock: false,
      unit: '500g',
    ),
    ProductEntity(
      id: 'p5',
      name: 'Fresh Whole Milk',
      description:
          'Rich and creamy fresh whole milk. A good source of calcium and vitamin D. Sourced from healthy, grass-fed cows.',
      price: 89,
      originalPrice: 109,
      imageUrl:
          'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400',
      category: 'Dairy',
      rating: 4.9,
      reviewCount: 1500,
      tags: ['Fresh', 'Dairy', 'Rich'],
      unit: '1 L',
    ),
    ProductEntity(
      id: 'p6',
      name: 'Whole Wheat Bread',
      description:
          'Soft and nutritious whole wheat bread. Perfect for sandwiches and morning toast. Baked fresh daily with no preservatives.',
      price: 45,
      originalPrice: 65,
      imageUrl:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
      category: 'Groceries',
      rating: 4.6,
      reviewCount: 780,
      tags: ['Nutritious', 'Whole Wheat', 'Soft'],
      unit: '400g',
    ),
    ProductEntity(
      id: 'p7',
      name: 'Farm Fresh Eggs',
      description:
          'A dozen farm fresh large brown eggs. Perfect for baking, breakfast, and cooking. Free-range and naturally raised.',
      price: 79,
      originalPrice: 99,
      imageUrl:
          'https://images.unsplash.com/photo-1506976785307-8732e854ad03?w=400',
      category: 'Groceries',
      rating: 4.8,
      reviewCount: 1100,
      tags: ['Farm Fresh', 'Brown Eggs', 'Protein'],
      isFavorite: true,
      unit: '12 pcs',
    ),
    ProductEntity(
      id: 'p8',
      name: 'Fresh Oranges',
      description:
          'Juicy and sweet fresh oranges. Packed with Vitamin C, great for fresh juice. Imported from the finest orchards.',
      price: 89,
      originalPrice: 129,
      imageUrl:
          'https://images.unsplash.com/photo-1557800636-894a64c1696f?w=400',
      category: 'Fruits',
      rating: 4.7,
      reviewCount: 920,
      tags: ['Juicy', 'Vitamin C', 'Sweet'],
      unit: '6 pcs',
    ),
    ProductEntity(
      id: 'p9',
      name: 'Fresh Carrots',
      description:
          'Sweet and crunchy fresh carrots. Great for snacking, cooking, or making carrot juice. A staple in every healthy kitchen.',
      price: 39,
      originalPrice: 59,
      imageUrl:
          'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400',
      category: 'Vegetables',
      rating: 4.6,
      reviewCount: 540,
      tags: ['Fresh', 'Crunchy', 'Sweet'],
      unit: '500g',
    ),
    ProductEntity(
      id: 'p10',
      name: 'Cheddar Cheese',
      description:
          'Rich and sharp cheddar cheese block. Perfect for grating, slicing, or melting. Aged to perfection for the finest flavour.',
      price: 149,
      originalPrice: 199,
      imageUrl:
          'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400',
      category: 'Dairy',
      rating: 4.7,
      reviewCount: 670,
      tags: ['Rich', 'Sharp', 'Dairy'],
      inStock: false,
      unit: '200g',
    ),
    ProductEntity(
      id: 'p11',
      name: 'Potato Chips',
      description:
          'Crispy and lightly salted classic potato chips. The perfect snack for movie nights and gatherings.',
      price: 30,
      originalPrice: 40,
      imageUrl:
          'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400',
      category: 'Snacks',
      rating: 4.4,
      reviewCount: 1300,
      tags: ['Crispy', 'Salty', 'Snack'],
      unit: '150g',
    ),
    ProductEntity(
      id: 'p12',
      name: 'Choco Chip Cookies',
      description:
          'Delicious chocolate chip cookies with a soft centre and crispy edges. Made with premium Belgian chocolate.',
      price: 45,
      originalPrice: 65,
      imageUrl:
          'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400',
      category: 'Snacks',
      rating: 4.8,
      reviewCount: 1450,
      tags: ['Delicious', 'Sweet', 'Soft'],
      isFavorite: true,
      unit: '200g',
    ),
  ];

  // Products the user has previously ordered
  static const List<String> orderedProductIds = [
    'p1', 'p2', 'p5', 'p7', 'p8', 'p9', 'p11', 'p12',
  ];

  static const UserEntity currentUser = UserEntity(
    id: 'u1',
    name: 'veggie mart user',
    email: 'veggiemartuser@email.com',
    phone: '+91 98765 43210',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    address: '12, Vaishali Nagar, Jaipur, Rajasthan 302021',
  );
}

