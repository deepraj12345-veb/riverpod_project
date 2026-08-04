// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get myProfile => 'My Profile';

  @override
  String get orders => 'Orders';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get cart => 'Cart';

  @override
  String get wallet => 'Wallet';

  @override
  String get addresses => 'Addresses';

  @override
  String get offers => 'Offers';

  @override
  String get accountSettings => 'ACCOUNT SETTINGS';

  @override
  String get subscription => 'Subscription';

  @override
  String get couponsAndOffers => 'Coupons & Offers';

  @override
  String get myAddresses => 'My Addresses';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get orderHistory => 'Order History';

  @override
  String get notifications => 'Notifications';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get signOut => 'Sign Out';

  @override
  String get failedToLoadProfile => 'Failed to load profile';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get signOutConfirmation =>
      'Are you sure you want to sign out of Veg king?';

  @override
  String get premiumActive => 'Premium Active';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get premiumMember => 'Premium Member';

  @override
  String get availablePromoCodes => 'Available promo codes & discounts';

  @override
  String get addDeliveryAddress => 'Add your delivery address';

  @override
  String savedAddresses(int count) {
    return '$count saved addresses';
  }

  @override
  String get upiCardsWallets => 'UPI, Cards, Wallets';

  @override
  String ordersCompleted(int count) {
    return '$count orders completed';
  }

  @override
  String get pushNotificationsEnabled => 'Push notifications enabled';

  @override
  String get faqsContactUs => 'FAQs, contact us';

  @override
  String get language => 'Language';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get searchProducts => 'Search products, brands, tags…';

  @override
  String get chefsPicksBestsellers => 'Chef\'s Picks & Bestsellers';

  @override
  String get trendingNearYou => 'Trending Near You';

  @override
  String get discoverTopProducts => 'Discover the top products trending today';

  @override
  String get shopByType => 'Shop by Type';

  @override
  String get allProducts => 'All Products';

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String get selectDeliveryAddress => 'Select Delivery Address';

  @override
  String get freshVeggieMart => 'Veg king';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get tryDifferentSearch => 'Try a different search or category';

  @override
  String get home => 'Home';

  @override
  String get categories => 'Categories';

  @override
  String get myCart => 'My Cart';

  @override
  String get clearAll => 'Clear all';

  @override
  String get selectPaymentMethod => 'Select Payment Method';

  @override
  String get maxTenUnits => 'Maximum 10 units allowed per item';

  @override
  String get orderTypeDeliverySchedule => 'Order Type & Delivery Schedule';

  @override
  String get oneTime => 'One Time';

  @override
  String get oneWeek => '1 Week';

  @override
  String get fifteenDays => '15 Days';

  @override
  String get oneMonth => '1 Month';

  @override
  String get customDates => 'Custom Dates';

  @override
  String get billDetails => 'Bill Details';

  @override
  String get itemTotal => 'Item Total';

  @override
  String get gst => 'GST (5%)';

  @override
  String get handlingFee => 'Handling Fee';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get toPay => 'To Pay';

  @override
  String get payUsing => 'Pay using';

  @override
  String get selectPayment => 'Select Payment';

  @override
  String get totalText => 'TOTAL';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get savingsCorner => 'SAVINGS CORNER';

  @override
  String get applyCoupon => 'Apply Coupon';

  @override
  String get yourCartIsEmpty => 'Your Cart is Empty';

  @override
  String get nothingInCart =>
      'Looks like you haven\'t added\nanything to your cart yet.';

  @override
  String get startShopping => 'Start Shopping';

  @override
  String paymentFailed(String message) {
    return 'Payment Failed: $message';
  }

  @override
  String externalWallet(String wallet) {
    return 'External Wallet Selected: $wallet';
  }

  @override
  String get orderPlaced => 'Order Placed!';

  @override
  String get orderSuccessMessage =>
      'Your order has been placed successfully.\nExpected delivery in 30 minutes.';

  @override
  String get continueShopping => 'Continue Shopping';

  @override
  String resultsForQuery(String query) {
    return 'Results for \"$query\"';
  }

  @override
  String get somethingWentWrong => 'Something went wrong!\nTry again.';

  @override
  String get whatAreYouLookingFor => 'What are you looking for?';

  @override
  String get searchForFreshVeggies => 'Search for fresh veggies, fruits & more';

  @override
  String get tryCheckingTypos =>
      'Try checking for typos or searching a general term';
}
