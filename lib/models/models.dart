import 'dart:typed_data';

// ── Membership ──────────────────────────────────────────────────────────────

enum MembershipTier { normal, vip, executiveVip }

extension MembershipTierX on MembershipTier {
  String get label {
    switch (this) {
      case MembershipTier.normal:
        return 'Normal';
      case MembershipTier.vip:
        return 'VIP';
      case MembershipTier.executiveVip:
        return 'Executive VIP';
    }
  }

  String get shortLabel {
    switch (this) {
      case MembershipTier.normal:
        return 'NORMAL';
      case MembershipTier.vip:
        return 'VIP';
      case MembershipTier.executiveVip:
        return 'EXEC VIP';
    }
  }

  /// One-time registration fee in THB.
  double get fee {
    switch (this) {
      case MembershipTier.normal:
        return 5000;
      case MembershipTier.vip:
        return 10000;
      case MembershipTier.executiveVip:
        return 100000;
    }
  }

  /// Direct referral commission = 10 % of fee.
  double get referralCommission => fee * 0.1;

  /// Maximum product listing price (null = unlimited).
  double? get maxSellPrice {
    switch (this) {
      case MembershipTier.normal:
        return 9000;
      case MembershipTier.vip:
        return 90000;
      case MembershipTier.executiveVip:
        return null;
    }
  }

  /// Minimum product listing price (null = no lower bound).
  double? get minSellPrice {
    switch (this) {
      case MembershipTier.normal:
        return null;
      case MembershipTier.vip:
        return 1000;
      case MembershipTier.executiveVip:
        return 1000;
    }
  }

  String get sellRangeLabel {
    switch (this) {
      case MembershipTier.normal:
        return 'Up to ฿9,000 per item';
      case MembershipTier.vip:
        return '฿1,000 – ฿90,000 per item';
      case MembershipTier.executiveVip:
        return '฿1,000+ (no upper limit)';
    }
  }

  String get buyAccessLabel {
    switch (this) {
      case MembershipTier.normal:
        return 'Normal products only';
      case MembershipTier.vip:
        return 'Normal & VIP products';
      case MembershipTier.executiveVip:
        return 'All product levels';
    }
  }

  /// Returns true if a member of this tier can browse/purchase a product
  /// that requires [productTier].
  bool canAccessTier(MembershipTier productTier) {
    switch (this) {
      case MembershipTier.normal:
        return productTier == MembershipTier.normal;
      case MembershipTier.vip:
        return productTier != MembershipTier.executiveVip;
      case MembershipTier.executiveVip:
        return true;
    }
  }
}

// ── Order status ─────────────────────────────────────────────────────────────

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Awaiting Confirmation';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'In Transit';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

// ── Domain models ────────────────────────────────────────────────────────────

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final MembershipTier membershipTier;

  /// This user's own unique invite code.
  final String referralCode;

  /// The invite code used when this user registered (if any).
  final String? referredBy;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.membershipTier,
    required this.referralCode,
    this.referredBy,
  });
}

class Product {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final Uint8List? imageBytes;
  final List<String> images;
  final String category;
  final double rating;
  final int reviewCount;
  final String description;
  final String? badge;
  final List<String> sizes;

  /// Minimum membership tier required to browse / purchase this product.
  final MembershipTier requiredTier;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.imageBytes,
    this.images = const [],
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.description,
    this.badge,
    this.sizes = const [],
    this.requiredTier = MembershipTier.normal,
  });
}

class CartItem {
  final Product product;
  int quantity;
  String? variant;

  CartItem({required this.product, this.quantity = 1, this.variant});
}

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final String address;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });
}

/// A single direct-referral event recorded for the current user.
class ReferralRecord {
  final String id;
  final String refereeId;
  final String refereeName;
  final MembershipTier refereeTier;
  final double commissionEarned;
  final DateTime joinedAt;

  ReferralRecord({
    required this.id,
    required this.refereeId,
    required this.refereeName,
    required this.refereeTier,
    required this.commissionEarned,
    required this.joinedAt,
  });
}

// ── Seller listing ────────────────────────────────────────────────────────────

enum ListingStatus { active, draft, outOfStock }

extension ListingStatusX on ListingStatus {
  String get label {
    switch (this) {
      case ListingStatus.active:
        return 'Active';
      case ListingStatus.draft:
        return 'Draft';
      case ListingStatus.outOfStock:
        return 'Out of Stock';
    }
  }
}

class MockSaleEvent {
  final DateTime date;
  final int unitsSold;
  final double revenue;

  const MockSaleEvent({required this.date, required this.unitsSold, required this.revenue});
}

const _kImageBytesSentinel = _BytesSentinel();

class _BytesSentinel {
  const _BytesSentinel();
}

class SellerListing {
  final String id;
  final String sellerId;
  String name;
  double price;
  String imageUrl;
  final Uint8List? imageBytes;
  String category;
  String description;
  MembershipTier requiredTier;
  int stock;
  ListingStatus status;
  final DateTime createdAt;
  final List<MockSaleEvent> salesHistory;

  SellerListing({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.imageBytes,
    required this.category,
    required this.description,
    required this.requiredTier,
    required this.stock,
    required this.status,
    required this.createdAt,
    this.salesHistory = const [],
  });

  int get unitsSold => salesHistory.fold(0, (sum, e) => sum + e.unitsSold);
  double get revenue => salesHistory.fold(0.0, (sum, e) => sum + e.revenue);

  Product toProduct() => Product(
    id: id,
    name: name,
    price: price,
    imageUrl: imageUrl,
    category: category,
    rating: 4.5,
    reviewCount: unitsSold,
    description: description,
    requiredTier: requiredTier,
    imageBytes: imageBytes,
  );

  SellerListing copyWith({
    String? name,
    double? price,
    String? imageUrl,
    String? category,
    String? description,
    MembershipTier? requiredTier,
    int? stock,
    ListingStatus? status,
    Object? imageBytes = _kImageBytesSentinel,
  }) {
    return SellerListing(
      id: id,
      sellerId: sellerId,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      description: description ?? this.description,
      requiredTier: requiredTier ?? this.requiredTier,
      stock: stock ?? this.stock,
      status: status ?? this.status,
      createdAt: createdAt,
      salesHistory: salesHistory,
      imageBytes: imageBytes is _BytesSentinel ? this.imageBytes : imageBytes as Uint8List?,
    );
  }
}
