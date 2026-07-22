import 'package:flutter/widgets.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

class AppState extends ChangeNotifier {
  bool isLoggedIn = false;
  AppUser? currentUser;
  List<CartItem> cart = [];
  List<Order> orders = [];
  String? lastOrderId;
  double commissionBalance = 0;
  List<ReferralRecord> referralHistory = [];

  /// Valid referral codes for the current UI-only session.
  final Map<String, String> _knownReferralCodes = {'GOLD100': 'James Sterling'};
  final Map<String, List<ReferralRecord>> _referralsByCode = {};
  final List<SellerListing> _sellerListings = [];

  AppState() {
    _referralsByCode['GOLD100'] = [
      ReferralRecord(
        id: 'ref1',
        refereeId: 'u_s1',
        refereeName: 'Somsak K.',
        refereeTier: MembershipTier.normal,
        commissionEarned: 500,
        joinedAt: DateTime(2025, 5, 10),
      ),
      ReferralRecord(
        id: 'ref2',
        refereeId: 'u_s2',
        refereeName: 'Wanida P.',
        refereeTier: MembershipTier.vip,
        commissionEarned: 1000,
        joinedAt: DateTime(2025, 6, 3),
      ),
      ReferralRecord(
        id: 'ref3',
        refereeId: 'u_s3',
        refereeName: 'Thanakorn S.',
        refereeTier: MembershipTier.normal,
        commissionEarned: 500,
        joinedAt: DateTime(2025, 7, 15),
      ),
      ReferralRecord(
        id: 'ref4',
        refereeId: 'u_s4',
        refereeName: 'Nattaporn C.',
        refereeTier: MembershipTier.normal,
        commissionEarned: 500,
        joinedAt: DateTime(2025, 7, 20),
      ),
    ];
    orders = [
      Order(
        id: 'ORD-001',
        items: [CartItem(product: mockProducts[0], quantity: 1)],
        total: 25000 + 250,
        address: '88 Sukhumvit Rd, Watthana, Bangkok 10110',
        paymentMethod: 'Bank Transfer',
        status: OrderStatus.delivered,
        createdAt: DateTime(2025, 6, 15),
      ),
      Order(
        id: 'ORD-002',
        items: [
          CartItem(product: mockProducts[1], quantity: 2),
          CartItem(product: mockProducts[2], quantity: 1),
        ],
        total: 4500 * 2 + 3800 + 250,
        address: '45 Silom Rd, Bang Rak, Bangkok 10500',
        paymentMethod: 'E-Wallet',
        status: OrderStatus.shipped,
        createdAt: DateTime(2025, 7, 1),
      ),
    ];
    _sellerListings.addAll([
      SellerListing(
        id: 'sl1',
        sellerId: 'u1',
        name: 'Golden Silk Tie',
        price: 2500,
        imageUrl: 'https://picsum.photos/seed/tie1/400/400',
        category: 'Accessories',
        description: 'Hand-finished silk tie with a refined gold accent weave, designed for premium formal styling.',
        requiredTier: MembershipTier.vip,
        stock: 12,
        status: ListingStatus.active,
        createdAt: _monthsAgo(5),
        salesHistory: _buildSalesHistory(2500, [3, 4, 5, 6, 7, 8]),
      ),
      SellerListing(
        id: 'sl2',
        sellerId: 'u1',
        name: 'Genuine Leather Wallet',
        price: 1800,
        imageUrl: 'https://picsum.photos/seed/wallet1/400/400',
        category: 'Accessories',
        description: 'Compact genuine leather wallet with gold-toned detailing and multiple premium card compartments.',
        requiredTier: MembershipTier.vip,
        stock: 25,
        status: ListingStatus.active,
        createdAt: _monthsAgo(4),
        salesHistory: _buildSalesHistory(1800, [5, 6, 7, 8, 9, 10]),
      ),
      SellerListing(
        id: 'sl3',
        sellerId: 'u1',
        name: 'Sterling Silver Ring',
        price: 3200,
        imageUrl: 'https://picsum.photos/seed/ring1/400/400',
        category: 'Accessories',
        description: 'Elegant sterling silver ring with polished finishing and a timeless minimal silhouette.',
        requiredTier: MembershipTier.vip,
        stock: 8,
        status: ListingStatus.active,
        createdAt: _monthsAgo(3),
        salesHistory: _buildSalesHistory(3200, [1, 2, 3, 4, 2]),
      ),
      SellerListing(
        id: 'sl4',
        sellerId: 'u1',
        name: 'Vintage Silk Scarf',
        price: 2200,
        imageUrl: 'https://picsum.photos/seed/scarf1/400/400',
        category: 'Clothing',
        description: 'Vintage-inspired silk scarf with a soft drape and luminous detailing for elevated layering.',
        requiredTier: MembershipTier.vip,
        stock: 0,
        status: ListingStatus.outOfStock,
        createdAt: _monthsAgo(2),
        salesHistory: _buildSalesHistory(2200, [2, 3, 4, 5]),
      ),
      SellerListing(
        id: 'sl5',
        sellerId: 'u1',
        name: 'Gold Pen Set',
        price: 4500,
        imageUrl: 'https://picsum.photos/seed/pen1/400/400',
        category: 'Accessories',
        description: 'Luxury gold pen set presented in a premium case, ideal for gifting or executive desks.',
        requiredTier: MembershipTier.vip,
        stock: 3,
        status: ListingStatus.draft,
        createdAt: _monthsAgo(1),
      ),
    ]);
  }

  static DateTime _monthsAgo(int monthsAgo) {
    final now = DateTime.now();
    return DateTime(now.year, now.month - monthsAgo, 1);
  }

  static List<MockSaleEvent> _buildSalesHistory(double price, List<int> monthlyUnits) {
    return List.generate(monthlyUnits.length, (index) {
      final monthsAgo = monthlyUnits.length - index - 1;
      final units = monthlyUnits[index];
      return MockSaleEvent(date: _monthsAgo(monthsAgo), unitsSold: units, revenue: units * price);
    });
  }

  List<SellerListing> get ownListings =>
      _sellerListings.where((listing) => listing.sellerId == currentUser?.id).toList();

  List<Product> get catalogProducts {
    final catalog = List<Product>.from(mockProducts);
    for (final listing in _sellerListings) {
      if (listing.status == ListingStatus.active) {
        catalog.add(listing.toProduct());
      }
    }
    return catalog;
  }

  static String? validateSellerPrice(double price, MembershipTier tier) {
    if (price <= 0) return 'Price must be greater than zero';
    final min = tier.minSellPrice;
    final max = tier.maxSellPrice;
    if (min != null && price < min) {
      return 'Minimum listing price for ${tier.label} is ฿${min.toStringAsFixed(0)}';
    }
    if (max != null && price > max) {
      return 'Maximum listing price for ${tier.label} is ฿${max.toStringAsFixed(0)}';
    }
    return null;
  }

  void login(String email, String password) {
    currentUser = const AppUser(
      id: 'u1',
      name: 'James Sterling',
      email: 'james@premium.com',
      phone: '+66812345678',
      membershipTier: MembershipTier.vip,
      referralCode: 'GOLD100',
    );
    _loadReferralAccount('GOLD100');
    isLoggedIn = true;
    notifyListeners();
  }

  void register(AppUser user) {
    final referredBy = user.referredBy?.trim().toUpperCase();
    if (referredBy != null &&
        referredBy != user.referralCode.toUpperCase() &&
        _knownReferralCodes.containsKey(referredBy)) {
      final records = _referralsByCode.putIfAbsent(referredBy, () => []);
      if (!records.any((record) => record.refereeId == user.id)) {
        records.insert(
          0,
          ReferralRecord(
            id: 'ref_${user.id}',
            refereeId: user.id,
            refereeName: user.name,
            refereeTier: user.membershipTier,
            commissionEarned: user.membershipTier.referralCommission,
            joinedAt: DateTime.now(),
          ),
        );
      }
    }

    final ownCode = user.referralCode.trim().toUpperCase();
    _knownReferralCodes.putIfAbsent(ownCode, () => user.name);
    _referralsByCode.putIfAbsent(ownCode, () => []);
    currentUser = user;
    _loadReferralAccount(ownCode);
    isLoggedIn = true;
    notifyListeners();
  }

  void _loadReferralAccount(String code) {
    referralHistory = List.unmodifiable(_referralsByCode[code] ?? const []);
    commissionBalance = referralHistory.fold(0, (sum, record) => sum + record.commissionEarned);
  }

  void logout() {
    isLoggedIn = false;
    currentUser = null;
    cart = [];
    commissionBalance = 0;
    referralHistory = [];
    notifyListeners();
  }

  /// Returns true when [code] is a valid known referral code that is not the
  /// current user''s own code.
  bool isValidReferralCode(String code) {
    final upper = code.trim().toUpperCase();
    if (upper.isEmpty) return false;
    if (currentUser != null && upper == currentUser!.referralCode) return false;
    return _knownReferralCodes.containsKey(upper);
  }

  /// Returns the display name of the owner of [code], or null if unknown.
  String? getReferrerName(String code) => _knownReferralCodes[code.trim().toUpperCase()];

  /// Returns true when the current user''s membership allows them to access
  /// [product].
  bool canAccessProduct(Product product) {
    if (!isLoggedIn || currentUser == null) return false;
    return currentUser!.membershipTier.canAccessTier(product.requiredTier);
  }

  /// Generates a deterministic referral code from [userId] and [name].
  /// Useful for UI tests: the output depends only on the two inputs.
  static String generateReferralCode(String userId, String name) {
    final cleaned = name.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final prefix = cleaned.length >= 4 ? cleaned.substring(0, 4) : cleaned.padRight(4, 'X');
    final hash = userId.codeUnits.fold(0, (acc, c) => (acc * 31 + c) & 0xFFFF) % 9000 + 1000;
    return '$prefix$hash';
  }

  void addSellerListing(SellerListing listing) {
    _validateManagedListing(listing);
    if (_sellerListings.any((existing) => existing.id == listing.id)) {
      throw StateError('A listing with ID ${listing.id} already exists');
    }
    _sellerListings.insert(0, listing);
    notifyListeners();
  }

  void updateSellerListing(SellerListing updated) {
    _validateManagedListing(updated);
    final idx = _sellerListings.indexWhere(
      (listing) => listing.id == updated.id && listing.sellerId == currentUser!.id,
    );
    if (idx < 0) {
      throw StateError('Listing ${updated.id} was not found for this seller');
    }
    _sellerListings[idx] = updated;
    notifyListeners();
  }

  void deleteSellerListing(String listingId) {
    final user = currentUser;
    if (user == null) {
      throw StateError('Sign in before managing seller listings');
    }
    final idx = _sellerListings.indexWhere((listing) => listing.id == listingId && listing.sellerId == user.id);
    if (idx < 0) {
      throw StateError('Listing $listingId was not found for this seller');
    }
    _sellerListings.removeAt(idx);
    cart.removeWhere((item) => item.product.id == listingId);
    notifyListeners();
  }

  void _validateManagedListing(SellerListing listing) {
    final user = currentUser;
    if (user == null) {
      throw StateError('Sign in before managing seller listings');
    }
    if (listing.sellerId != user.id) {
      throw StateError('A seller can only manage their own listings');
    }
    final priceError = validateSellerPrice(listing.price, user.membershipTier);
    if (priceError != null) {
      throw ArgumentError.value(listing.price, 'price', priceError);
    }
    if (!user.membershipTier.canAccessTier(listing.requiredTier)) {
      throw ArgumentError.value(listing.requiredTier, 'requiredTier', 'Product tier exceeds the seller membership');
    }
    if (listing.stock < 0) {
      throw ArgumentError.value(listing.stock, 'stock', 'Stock cannot be negative');
    }
    if (listing.status == ListingStatus.active && listing.stock == 0) {
      throw ArgumentError.value(listing.stock, 'stock', 'Active listings must have available stock');
    }
  }

  void addToCart(Product product, {int quantity = 1, String? variant}) {
    final idx = cart.indexWhere((i) => i.product.id == product.id && i.variant == variant);
    if (idx >= 0) {
      cart[idx].quantity += quantity;
    } else {
      cart.add(CartItem(product: product, quantity: quantity, variant: variant));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    cart.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int qty) {
    if (qty <= 0) {
      removeFromCart(productId);
      return;
    }
    final idx = cart.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      cart[idx].quantity = qty;
      notifyListeners();
    }
  }

  void clearCart() {
    cart = [];
    notifyListeners();
  }

  void placeOrder(String address, String paymentMethod) {
    final orderId = 'ORD-${(orders.length + 1).toString().padLeft(3, '0')}';
    final order = Order(
      id: orderId,
      items: List.from(cart),
      total: cartTotal + 250,
      address: address,
      paymentMethod: paymentMethod,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );
    orders.insert(0, order);
    lastOrderId = orderId;
    clearCart();
  }

  int get cartCount => cart.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => cart.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({required AppState notifier, required super.child, super.key}) : super(notifier: notifier);

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.notifier!;
}
