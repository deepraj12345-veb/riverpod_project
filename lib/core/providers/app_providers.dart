import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/core/constants/fake_data.dart';
import 'package:veggie_mart/core/constants/data/models/models.dart';

// Auth Provider moved to lib/features/auth/presentation/providers/auth_provider.dart

// ─── User Provider ──────────────────────────────────────────────────────────────

final isPremiumUserProvider = StateProvider<bool>((ref) => false);
final activeSubscriptionPlanProvider = StateProvider<String?>((ref) => null);

// ─── Products Provider ──────────────────────────────────────────────────────────

class ProductsNotifier extends StateNotifier<List<ProductModel>> {
  ProductsNotifier() : super(List.from(FakeData.products));

  void toggleFavorite(String productId) {
    state = state.map((p) {
      if (p.id == productId) {
        return p.copyWith(isFavorite: !p.isFavorite);
      }
      return p;
    }).toList();
  }
}

final productsProvider =
    StateNotifierProvider<ProductsNotifier, List<ProductModel>>(
      (ref) => ProductsNotifier(),
    );

// ─── Selected Category ──────────────────────────────────────────────────────────

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// ─── Filtered Products ──────────────────────────────────────────────────────────

final filteredProductsProvider = Provider<List<ProductModel>>((ref) {
  final products = ref.watch(productsProvider);
  final category = ref.watch(selectedCategoryProvider);
  if (category == 'All') return products;
  return products.where((p) => p.category == category).toList();
});

// ─── Search Provider ────────────────────────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchedProductsProvider = Provider<List<ProductModel>>((ref) {
  final products = ref.watch(productsProvider);
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return products;
  return products
      .where(
        (p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.category.toLowerCase().contains(query.toLowerCase()),
      )
      .toList();
});

// ─── Cart Provider ──────────────────────────────────────────────────────────────

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  void addToCart(ProductModel product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      state = [...state, CartItemModel(product: product, quantity: 1)];
    } else {
      final updated = List<CartItemModel>.from(state);
      updated[index].quantity++;
      state = [...updated];
    }
  }

  void removeFromCart(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void incrementQuantity(String productId) {
    final updated = List<CartItemModel>.from(state);
    final index = updated.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      updated[index].quantity++;
      state = [...updated];
    }
  }

  void decrementQuantity(String productId) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (state[index].quantity <= 1) {
        removeFromCart(productId);
      } else {
        final updated = List<CartItemModel>.from(state);
        updated[index].quantity--;
        state = [...updated];
      }
    }
  }

  void clearCart() => state = [];

  double get totalAmount => state.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItems => state.fold(0, (sum, item) => sum + item.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>(
  (ref) => CartNotifier(),
);

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

// ─── Bottom Nav Provider ────────────────────────────────────────────────────────

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

// ─── OTP Provider ───────────────────────────────────────────────────────────────

class OtpNotifier extends StateNotifier<String> {
  OtpNotifier() : super('');

  static const String _mockOtp = '123456';

  void sendOtp() {
    // Simulate sending OTP
    state = _mockOtp;
  }

  bool verifyOtp(String enteredOtp) {
    return enteredOtp == _mockOtp;
  }
}

final otpProvider = StateNotifierProvider<OtpNotifier, String>(
  (ref) => OtpNotifier(),
);
