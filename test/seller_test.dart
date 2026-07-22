import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasi_2306089/models/models.dart';
import 'package:aplikasi_2306089/state/app_state.dart';

void main() {
  group('Seller price validation', () {
    test('normal tier boundaries are enforced', () {
      expect(AppState.validateSellerPrice(0, MembershipTier.normal), 'Price must be greater than zero');
      expect(AppState.validateSellerPrice(1, MembershipTier.normal), isNull);
      expect(AppState.validateSellerPrice(9000, MembershipTier.normal), isNull);
      expect(AppState.validateSellerPrice(9001, MembershipTier.normal), 'Maximum listing price for Normal is ฿9000');
    });

    test('vip tier boundaries are enforced', () {
      expect(AppState.validateSellerPrice(999, MembershipTier.vip), 'Minimum listing price for VIP is ฿1000');
      expect(AppState.validateSellerPrice(1000, MembershipTier.vip), isNull);
      expect(AppState.validateSellerPrice(90000, MembershipTier.vip), isNull);
      expect(AppState.validateSellerPrice(90001, MembershipTier.vip), 'Maximum listing price for VIP is ฿90000');
    });

    test('executive vip tier boundaries are enforced', () {
      expect(
        AppState.validateSellerPrice(999, MembershipTier.executiveVip),
        'Minimum listing price for Executive VIP is ฿1000',
      );
      expect(AppState.validateSellerPrice(1000, MembershipTier.executiveVip), isNull);
      expect(AppState.validateSellerPrice(250000, MembershipTier.executiveVip), isNull);
    });
  });

  group('Seller listing CRUD', () {
    late AppState state;

    setUp(() {
      state = AppState();
      state.login('james@premium.com', 'password');
    });

    test('add, update, and delete listing', () {
      final listing = SellerListing(
        id: 'sl_test',
        sellerId: state.currentUser!.id,
        name: 'Test Product',
        price: 2500,
        imageUrl: 'https://picsum.photos/seed/test-product/400/400',
        category: 'Accessories',
        description: 'Premium seller test listing for dashboard coverage.',
        requiredTier: MembershipTier.vip,
        stock: 5,
        status: ListingStatus.active,
        createdAt: DateTime(2026, 1, 1),
      );

      state.addSellerListing(listing);
      expect(state.ownListings.any((item) => item.id == 'sl_test'), isTrue);
      expect(state.catalogProducts.any((item) => item.id == 'sl_test'), isTrue);

      state.updateSellerListing(
        listing.copyWith(name: 'Updated Product', price: 3000, stock: 0, status: ListingStatus.outOfStock),
      );

      final updated = state.ownListings.firstWhere((item) => item.id == 'sl_test');
      expect(updated.name, 'Updated Product');
      expect(updated.price, 3000);
      expect(updated.stock, 0);
      expect(updated.status, ListingStatus.outOfStock);

      state.deleteSellerListing('sl_test');
      expect(state.ownListings.any((item) => item.id == 'sl_test'), isFalse);
      expect(state.catalogProducts.any((item) => item.id == 'sl_test'), isFalse);
    });

    test('deleting listing removes matching cart item', () {
      final listing = SellerListing(
        id: 'sl_cart',
        sellerId: state.currentUser!.id,
        name: 'Cart Product',
        price: 2400,
        imageUrl: 'https://picsum.photos/seed/cart-product/400/400',
        category: 'Accessories',
        description: 'Cart synchronization listing for seller removal testing.',
        requiredTier: MembershipTier.vip,
        stock: 2,
        status: ListingStatus.active,
        createdAt: DateTime(2026, 1, 2),
      );

      state.addSellerListing(listing);
      state.addToCart(listing.toProduct());
      expect(state.cart.any((item) => item.product.id == 'sl_cart'), isTrue);

      state.deleteSellerListing('sl_cart');
      expect(state.cart.any((item) => item.product.id == 'sl_cart'), isFalse);
    });

    test('state rejects listings outside seller permissions', () {
      expect(
        () => state.addSellerListing(
          SellerListing(
            id: 'sl_too_expensive',
            sellerId: state.currentUser!.id,
            name: 'Too Expensive',
            price: 90001,
            imageUrl: 'https://picsum.photos/seed/expensive/400/400',
            category: 'Accessories',
            description: 'A listing outside the VIP seller price range.',
            requiredTier: MembershipTier.vip,
            stock: 1,
            status: ListingStatus.active,
            createdAt: DateTime(2026, 1, 5),
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => state.addSellerListing(
          SellerListing(
            id: 'sl_other_seller',
            sellerId: 'another_user',
            name: 'Other Seller Product',
            price: 2500,
            imageUrl: 'https://picsum.photos/seed/other-seller/400/400',
            category: 'Accessories',
            description: 'A listing that belongs to another seller account.',
            requiredTier: MembershipTier.vip,
            stock: 1,
            status: ListingStatus.active,
            createdAt: DateTime(2026, 1, 5),
          ),
        ),
        throwsStateError,
      );
      expect(
        () => state.addSellerListing(
          SellerListing(
            id: 'sl_no_stock',
            sellerId: state.currentUser!.id,
            name: 'No Stock Product',
            price: 2500,
            imageUrl: 'https://picsum.photos/seed/no-stock/400/400',
            category: 'Accessories',
            description: 'An active listing without any available stock.',
            requiredTier: MembershipTier.vip,
            stock: 0,
            status: ListingStatus.active,
            createdAt: DateTime(2026, 1, 5),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('state rejects duplicate listing IDs and unauthorized deletion', () {
      final listing = SellerListing(
        id: 'sl_unique',
        sellerId: state.currentUser!.id,
        name: 'Unique Product',
        price: 2500,
        imageUrl: 'https://picsum.photos/seed/unique/400/400',
        category: 'Accessories',
        description: 'A uniquely identified product listing for sale.',
        requiredTier: MembershipTier.vip,
        stock: 1,
        status: ListingStatus.active,
        createdAt: DateTime(2026, 1, 5),
      );
      state.addSellerListing(listing);

      expect(() => state.addSellerListing(listing), throwsStateError);
      expect(() => state.deleteSellerListing('listing_owned_by_someone_else'), throwsStateError);
    });

    test('updating a listing replaces its gallery image bytes', () {
      final originalBytes = Uint8List.fromList([1, 2, 3]);
      final replacementBytes = Uint8List.fromList([4, 5, 6]);
      final listing = SellerListing(
        id: 'sl_image_update',
        sellerId: state.currentUser!.id,
        name: 'Gallery Product',
        price: 2500,
        imageUrl: '',
        imageBytes: originalBytes,
        category: 'Accessories',
        description: 'A product whose gallery image can be replaced.',
        requiredTier: MembershipTier.vip,
        stock: 1,
        status: ListingStatus.active,
        createdAt: DateTime(2026, 1, 5),
      );
      state.addSellerListing(listing);

      state.updateSellerListing(listing.copyWith(imageBytes: replacementBytes));

      final updated = state.ownListings.firstWhere((item) => item.id == listing.id);
      expect(updated.imageBytes, same(replacementBytes));
      expect(
        state.catalogProducts.firstWhere((product) => product.id == listing.id).imageBytes,
        same(replacementBytes),
      );
    });
  });

  group('Catalog synchronization', () {
    late AppState state;

    setUp(() {
      state = AppState();
      state.login('james@premium.com', 'password');
    });

    test('catalog only exposes active seller listings', () {
      final seededSellerIds = state.catalogProducts
          .where((product) => product.id.startsWith('sl'))
          .map((product) => product.id)
          .toList();

      expect(seededSellerIds, containsAll(<String>['sl1', 'sl2', 'sl3']));
      expect(seededSellerIds, isNot(contains('sl4')));
      expect(seededSellerIds, isNot(contains('sl5')));

      final draft = SellerListing(
        id: 'sl_draft',
        sellerId: state.currentUser!.id,
        name: 'Draft Listing',
        price: 1500,
        imageUrl: 'https://picsum.photos/seed/draft-product/400/400',
        category: 'Accessories',
        description: 'Draft seller listing that should stay hidden from catalog.',
        requiredTier: MembershipTier.normal,
        stock: 5,
        status: ListingStatus.draft,
        createdAt: DateTime(2026, 1, 3),
      );
      state.addSellerListing(draft);
      expect(state.catalogProducts.any((product) => product.id == 'sl_draft'), isFalse);

      final active = SellerListing(
        id: 'sl_active',
        sellerId: state.currentUser!.id,
        name: 'Active Listing',
        price: 2600,
        imageUrl: 'https://picsum.photos/seed/active-product/400/400',
        category: 'Accessories',
        description: 'Active seller listing that should appear in catalog.',
        requiredTier: MembershipTier.vip,
        stock: 4,
        status: ListingStatus.active,
        createdAt: DateTime(2026, 1, 4),
      );
      state.addSellerListing(active);
      expect(state.catalogProducts.any((product) => product.id == 'sl_active'), isTrue);

      state.updateSellerListing(active.copyWith(status: ListingStatus.draft));
      expect(state.catalogProducts.any((product) => product.id == 'sl_active'), isFalse);

      state.deleteSellerListing('sl_active');
      expect(state.catalogProducts.any((product) => product.id == 'sl_active'), isFalse);
    });
  });

  group('Seller seeded totals', () {
    test('seeded listings expose expected revenue and units sold totals', () {
      final state = AppState();
      state.login('james@premium.com', 'password');

      final listings = state.ownListings;
      final totalRevenue = listings.fold<double>(0, (sum, listing) => sum + listing.revenue);
      final totalUnits = listings.fold<int>(0, (sum, listing) => sum + listing.unitsSold);
      final activeListings = listings.where((listing) => listing.status == ListingStatus.active).length;

      expect(listings.length, 5);
      expect(totalRevenue, 232700);
      expect(totalUnits, 104);
      expect(activeListings, 3);
    });
  });

  group('SellerListing image bytes', () {
    test('imageBytes defaults to null', () {
      final listing = SellerListing(
        id: 'sl_bytes',
        sellerId: 'u1',
        name: 'Byte Product',
        price: 2500,
        imageUrl: '',
        category: 'Accessories',
        description: 'A listing to test image byte handling.',
        requiredTier: MembershipTier.vip,
        stock: 1,
        status: ListingStatus.active,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(listing.imageBytes, isNull);
    });

    test('imageBytes is propagated via constructor and toProduct', () {
      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final listing = SellerListing(
        id: 'sl_bytes2',
        sellerId: 'u1',
        name: 'Photo Product',
        price: 2500,
        imageUrl: '',
        imageBytes: bytes,
        category: 'Accessories',
        description: 'A listing with in-memory image bytes.',
        requiredTier: MembershipTier.vip,
        stock: 1,
        status: ListingStatus.active,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(listing.imageBytes, same(bytes));
      final product = listing.toProduct();
      expect(product.imageBytes, same(bytes));
    });

    test('copyWith preserves bytes when not specified', () {
      final bytes = Uint8List.fromList([10, 20, 30]);
      final listing = SellerListing(
        id: 'sl_bytes3',
        sellerId: 'u1',
        name: 'Original',
        price: 2500,
        imageUrl: '',
        imageBytes: bytes,
        category: 'Accessories',
        description: 'A listing for copyWith preservation test.',
        requiredTier: MembershipTier.vip,
        stock: 1,
        status: ListingStatus.active,
        createdAt: DateTime(2026, 1, 1),
      );
      final updated = listing.copyWith(name: 'Updated');
      expect(updated.imageBytes, same(bytes));
    });

    test('copyWith replaces bytes when new bytes provided', () {
      final oldBytes = Uint8List.fromList([1, 2, 3]);
      final newBytes = Uint8List.fromList([7, 8, 9]);
      final listing = SellerListing(
        id: 'sl_bytes4',
        sellerId: 'u1',
        name: 'Original',
        price: 2500,
        imageUrl: '',
        imageBytes: oldBytes,
        category: 'Accessories',
        description: 'A listing for copyWith replacement test.',
        requiredTier: MembershipTier.vip,
        stock: 1,
        status: ListingStatus.active,
        createdAt: DateTime(2026, 1, 1),
      );
      final updated = listing.copyWith(imageBytes: newBytes);
      expect(updated.imageBytes, same(newBytes));
    });

    test('copyWith clears bytes when null explicitly passed', () {
      final bytes = Uint8List.fromList([1, 2]);
      final listing = SellerListing(
        id: 'sl_bytes5',
        sellerId: 'u1',
        name: 'Original',
        price: 2500,
        imageUrl: 'https://example.com/img.jpg',
        imageBytes: bytes,
        category: 'Accessories',
        description: 'A listing for copyWith null-clear test.',
        requiredTier: MembershipTier.vip,
        stock: 1,
        status: ListingStatus.active,
        createdAt: DateTime(2026, 1, 1),
      );
      final updated = listing.copyWith(imageBytes: null);
      expect(updated.imageBytes, isNull);
    });

    test('seeded listings have null imageBytes and valid imageUrl', () {
      final state = AppState();
      state.login('james@premium.com', 'password');
      for (final listing in state.ownListings) {
        expect(listing.imageBytes, isNull);
        expect(listing.imageUrl, isNotEmpty);
        final product = listing.toProduct();
        expect(product.imageBytes, isNull);
        expect(product.imageUrl, isNotEmpty);
      }
    });
  });
}
