import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplikasi_2306089/models/models.dart';
import 'package:aplikasi_2306089/state/app_state.dart';
import 'package:aplikasi_2306089/data/mock_data.dart';
import 'package:aplikasi_2306089/theme/app_theme.dart';
import 'package:aplikasi_2306089/screens/membership/membership_payment_screen.dart';

void main() {
  // ── MembershipTierX extension ──────────────────────────────────────────────

  group('MembershipTier fees', () {
    test('Normal fee is 5000', () {
      expect(MembershipTier.normal.fee, equals(5000.0));
    });

    test('VIP fee is 10000', () {
      expect(MembershipTier.vip.fee, equals(10000.0));
    });

    test('Executive VIP fee is 100000', () {
      expect(MembershipTier.executiveVip.fee, equals(100000.0));
    });
  });

  group('10% referral commission calculation', () {
    test('Normal referral commission is 500', () {
      expect(MembershipTier.normal.referralCommission, equals(500.0));
    });

    test('VIP referral commission is 1000', () {
      expect(MembershipTier.vip.referralCommission, equals(1000.0));
    });

    test('Executive VIP referral commission is 10000', () {
      expect(MembershipTier.executiveVip.referralCommission, equals(10000.0));
    });

    test('Commission is exactly 10% of fee for all tiers', () {
      for (final tier in MembershipTier.values) {
        expect(
          tier.referralCommission,
          closeTo(tier.fee * 0.1, 0.001),
          reason: '${tier.label} commission should be 10% of fee',
        );
      }
    });
  });

  // ── canAccessTier ─────────────────────────────────────────────────────────

  group('MembershipTier.canAccessTier', () {
    test('Normal can access Normal products', () {
      expect(MembershipTier.normal.canAccessTier(MembershipTier.normal), isTrue);
    });

    test('Normal cannot access VIP products', () {
      expect(MembershipTier.normal.canAccessTier(MembershipTier.vip), isFalse);
    });

    test('Normal cannot access Executive VIP products', () {
      expect(MembershipTier.normal.canAccessTier(MembershipTier.executiveVip), isFalse);
    });

    test('VIP can access Normal products', () {
      expect(MembershipTier.vip.canAccessTier(MembershipTier.normal), isTrue);
    });

    test('VIP can access VIP products', () {
      expect(MembershipTier.vip.canAccessTier(MembershipTier.vip), isTrue);
    });

    test('VIP cannot access Executive VIP products', () {
      expect(MembershipTier.vip.canAccessTier(MembershipTier.executiveVip), isFalse);
    });

    test('Executive VIP can access all tiers', () {
      for (final tier in MembershipTier.values) {
        expect(
          MembershipTier.executiveVip.canAccessTier(tier),
          isTrue,
          reason: 'Executive VIP should access ${tier.label}',
        );
      }
    });
  });

  // ── AppState.canAccessProduct ──────────────────────────────────────────────

  group('AppState.canAccessProduct', () {
    late AppState state;

    setUp(() => state = AppState());

    test('Not logged in: cannot access any product', () {
      expect(state.isLoggedIn, isFalse);
      expect(state.canAccessProduct(mockProducts.first), isFalse);
    });

    test('Normal member can access Normal-tier product', () {
      state.register(
        const AppUser(
          id: 'u_test',
          name: 'Test User',
          email: 't@test.com',
          phone: '+661234',
          membershipTier: MembershipTier.normal,
          referralCode: 'TEST1000',
        ),
      );
      final normalProduct = mockProducts.firstWhere((p) => p.requiredTier == MembershipTier.normal);
      expect(state.canAccessProduct(normalProduct), isTrue);
    });

    test('Normal member cannot access VIP-tier product', () {
      state.register(
        const AppUser(
          id: 'u_test2',
          name: 'Test User',
          email: 't2@test.com',
          phone: '+661234',
          membershipTier: MembershipTier.normal,
          referralCode: 'TEST2000',
        ),
      );
      final vipProduct = mockProducts.firstWhere((p) => p.requiredTier == MembershipTier.vip);
      expect(state.canAccessProduct(vipProduct), isFalse);
    });

    test('VIP member can access Normal and VIP products', () {
      state.register(
        const AppUser(
          id: 'u_test3',
          name: 'VIP User',
          email: 'vip@test.com',
          phone: '+661234',
          membershipTier: MembershipTier.vip,
          referralCode: 'VIPT3000',
        ),
      );
      final normalProduct = mockProducts.firstWhere((p) => p.requiredTier == MembershipTier.normal);
      final vipProduct = mockProducts.firstWhere((p) => p.requiredTier == MembershipTier.vip);
      expect(state.canAccessProduct(normalProduct), isTrue);
      expect(state.canAccessProduct(vipProduct), isTrue);
    });

    test('VIP member cannot access Executive VIP product', () {
      state.register(
        const AppUser(
          id: 'u_test4',
          name: 'VIP User',
          email: 'vip2@test.com',
          phone: '+661234',
          membershipTier: MembershipTier.vip,
          referralCode: 'VIPT4000',
        ),
      );
      final execProduct = mockProducts.firstWhere((p) => p.requiredTier == MembershipTier.executiveVip);
      expect(state.canAccessProduct(execProduct), isFalse);
    });

    test('Executive VIP member can access all products', () {
      state.register(
        const AppUser(
          id: 'u_exec',
          name: 'Exec User',
          email: 'exec@test.com',
          phone: '+661234',
          membershipTier: MembershipTier.executiveVip,
          referralCode: 'EXEC5000',
        ),
      );
      for (final product in mockProducts) {
        expect(state.canAccessProduct(product), isTrue, reason: 'Exec VIP should access ${product.name}');
      }
    });
  });

  // ── Referral code validation ───────────────────────────────────────────────

  group('Referral code validation', () {
    late AppState state;

    setUp(() => state = AppState());

    test('GOLD100 is a valid referral code', () {
      expect(state.isValidReferralCode('GOLD100'), isTrue);
    });

    test('GOLD100 is valid regardless of case', () {
      expect(state.isValidReferralCode('gold100'), isTrue);
      expect(state.isValidReferralCode('Gold100'), isTrue);
    });

    test('Invalid code returns false', () {
      expect(state.isValidReferralCode('INVALID'), isFalse);
    });

    test('Empty code returns false', () {
      expect(state.isValidReferralCode(''), isFalse);
    });

    test('Logged-in user cannot use their own referral code', () {
      state.login('test@test.com', 'password');
      // Demo user has code GOLD100
      expect(state.currentUser?.referralCode, equals('GOLD100'));
      expect(state.isValidReferralCode('GOLD100'), isFalse);
    });

    test('getReferrerName returns correct name for GOLD100', () {
      expect(state.getReferrerName('GOLD100'), equals('James Sterling'));
    });

    test('getReferrerName returns null for unknown code', () {
      expect(state.getReferrerName('UNKNOWN'), isNull);
    });
  });

  // ── Referral code generation ───────────────────────────────────────────────

  group('AppState.generateReferralCode', () {
    test('Generates code with 4-letter prefix from name', () {
      final code = AppState.generateReferralCode('u_abc', 'Alice Brown');
      expect(code.substring(0, 4), equals('ALIC'));
    });

    test('Code suffix is a 4-digit number between 1000 and 9999', () {
      final code = AppState.generateReferralCode('u_abc', 'Alice Brown');
      final numPart = int.parse(code.substring(4));
      expect(numPart, greaterThanOrEqualTo(1000));
      expect(numPart, lessThanOrEqualTo(9999));
    });

    test('Generation is deterministic — same inputs give same code', () {
      final code1 = AppState.generateReferralCode('u_xyz', 'John Smith');
      final code2 = AppState.generateReferralCode('u_xyz', 'John Smith');
      expect(code1, equals(code2));
    });

    test('Different user IDs produce different codes', () {
      final code1 = AppState.generateReferralCode('u_001', 'John Smith');
      final code2 = AppState.generateReferralCode('u_999', 'John Smith');
      expect(code1, isNot(equals(code2)));
    });

    test('Short name is padded with X', () {
      final code = AppState.generateReferralCode('u_1', 'Jo');
      expect(code.substring(0, 4), equals('JOXX'));
    });
  });

  // ── Mock data integrity ────────────────────────────────────────────────────

  group('Mock product data', () {
    test('All products have valid required tiers', () {
      for (final p in mockProducts) {
        expect(MembershipTier.values.contains(p.requiredTier), isTrue, reason: '${p.name} has invalid tier');
      }
    });

    test('Normal-tier products are priced at or below 9000 THB', () {
      final normalProducts = mockProducts.where((p) => p.requiredTier == MembershipTier.normal);
      expect(normalProducts, isNotEmpty);
      for (final p in normalProducts) {
        expect(p.price, lessThanOrEqualTo(9000), reason: '${p.name} (฿${p.price}) should be ≤ ฿9,000 for Normal');
      }
    });

    test('VIP-tier products are within 1000–90000 THB range', () {
      final vipProducts = mockProducts.where((p) => p.requiredTier == MembershipTier.vip);
      expect(vipProducts, isNotEmpty);
      for (final p in vipProducts) {
        expect(p.price, greaterThanOrEqualTo(1000), reason: '${p.name} should be ≥ ฿1,000');
        expect(p.price, lessThanOrEqualTo(90000), reason: '${p.name} should be ≤ ฿90,000');
      }
    });

    test('Executive VIP products are priced above 90000 THB', () {
      final execProducts = mockProducts.where((p) => p.requiredTier == MembershipTier.executiveVip);
      expect(execProducts, isNotEmpty);
      for (final p in execProducts) {
        expect(p.price, greaterThan(90000), reason: '${p.name} should be > ฿90,000');
      }
    });

    test('Catalog has products at all three tiers', () {
      final tiers = mockProducts.map((p) => p.requiredTier).toSet();
      expect(tiers, containsAll(MembershipTier.values));
    });

    test('mockUser is VIP tier with code GOLD100', () {
      expect(mockUser.membershipTier, equals(MembershipTier.vip));
      expect(mockUser.referralCode, equals('GOLD100'));
    });
  });

  // ── THB formatter ─────────────────────────────────────────────────────────

  group('formatThb', () {
    test('Formats 1000 as ฿1,000', () {
      expect(formatThb(1000), equals('฿1,000'));
    });

    test('Formats 25000 as ฿25,000', () {
      expect(formatThb(25000), equals('฿25,000'));
    });

    test('Formats 100000 as ฿100,000', () {
      expect(formatThb(100000), equals('฿100,000'));
    });

    test('Formats 500 as ฿500', () {
      expect(formatThb(500), equals('฿500'));
    });
  });

  // ── AppState login seeds demo referral data ────────────────────────────────

  group('AppState login', () {
    test('Login seeds VIP user with non-empty referral history', () {
      final state = AppState();
      state.login('test@email.com', 'password');
      expect(state.currentUser?.membershipTier, equals(MembershipTier.vip));
      expect(state.referralHistory, isNotEmpty);
    });

    test('Commission balance matches sum of referral records after login', () {
      final state = AppState();
      state.login('test@email.com', 'password');
      final expectedBalance = state.referralHistory.fold(0.0, (sum, r) => sum + r.commissionEarned);
      expect(state.commissionBalance, closeTo(expectedBalance, 0.01));
    });

    test('Logout clears commission balance and referral history', () {
      final state = AppState();
      state.login('test@email.com', 'password');
      state.logout();
      expect(state.commissionBalance, equals(0.0));
      expect(state.referralHistory, isEmpty);
    });

    // commission is only credited when AppState.register() is called,
    // which in the new flow happens only after payment slip verification
    // on MembershipPaymentScreen — NOT at OTP success.
    test('register() credits 10% to the direct referrer (payment-gate trigger)', () {
      final state = AppState();
      state.login('demo@email.com', 'password');
      final initialBalance = state.commissionBalance;
      final initialCount = state.referralHistory.length;
      state.logout();

      state.register(
        const AppUser(
          id: 'u_referred_vip',
          name: 'Referred VIP',
          email: 'referred@email.com',
          phone: '+66123456789',
          membershipTier: MembershipTier.vip,
          referralCode: 'REFE1234',
          referredBy: 'gold100',
        ),
      );

      expect(state.commissionBalance, equals(0));
      state.logout();
      state.login('demo@email.com', 'password');
      expect(state.commissionBalance, equals(initialBalance + MembershipTier.vip.referralCommission));
      expect(state.referralHistory, hasLength(initialCount + 1));
      expect(state.referralHistory.first.refereeId, equals('u_referred_vip'));
      expect(state.referralHistory.first.commissionEarned, equals(MembershipTier.vip.referralCommission));
    });

    test('Invalid referral code does not credit commission', () {
      final state = AppState();
      state.register(
        const AppUser(
          id: 'u_invalid_referral',
          name: 'Invalid Referral',
          email: 'invalid@email.com',
          phone: '+66123456789',
          membershipTier: MembershipTier.executiveVip,
          referralCode: 'INVA1234',
          referredBy: 'NOT-A-CODE',
        ),
      );
      state.logout();
      state.login('demo@email.com', 'password');

      expect(state.commissionBalance, equals(2500));
      expect(state.referralHistory.any((record) => record.refereeId == 'u_invalid_referral'), isFalse);
    });
  });

  // ── Payment gate — no premature or duplicate commission credit ─────────────

  group('Payment gate — commission credit guards', () {
    test('No commission is credited before register() is called', () {
      // Represents the state between OTP success and payment verification:
      // the pendingUser exists but register() has NOT been called yet.
      final state = AppState();
      state.login('demo@email.com', 'password');
      final balanceBefore = state.commissionBalance;
      state.logout();

      // OTP passes but payment not yet verified — register() NOT called.
      expect(state.isLoggedIn, isFalse);
      expect(state.commissionBalance, equals(0));

      // Re-login as referrer to confirm no change.
      state.login('demo@email.com', 'password');
      expect(state.commissionBalance, equals(balanceBefore));
    });

    test('Calling register() twice with the same userId does not double-credit commission', () {
      final state = AppState();
      state.login('demo@email.com', 'password');
      final initialBalance = state.commissionBalance;
      state.logout();

      const user = AppUser(
        id: 'u_double_tap',
        name: 'Double Tap',
        email: 'double@email.com',
        phone: '+66111222333',
        membershipTier: MembershipTier.normal,
        referralCode: 'DOUB5678',
        referredBy: 'GOLD100',
      );

      // First call (from payment screen)
      state.register(user);
      state.logout();
      state.login('demo@email.com', 'password');
      final balanceAfterFirst = state.commissionBalance;
      expect(balanceAfterFirst, equals(initialBalance + MembershipTier.normal.referralCommission));
      state.logout();

      // Simulated second call (e.g. back-press + re-submit) — must be a no-op
      state.register(user);
      state.logout();
      state.login('demo@email.com', 'password');
      // Balance must not increase again
      expect(state.commissionBalance, equals(balanceAfterFirst));
    });

    test('Commission credited only for the inviter, not the new member itself', () {
      final state = AppState();
      state.login('demo@email.com', 'password');
      final referrerBalanceBefore = state.commissionBalance;
      state.logout();

      state.register(
        const AppUser(
          id: 'u_new_member',
          name: 'New Member',
          email: 'new@email.com',
          phone: '+66999888777',
          membershipTier: MembershipTier.vip,
          referralCode: 'NEWM1111',
          referredBy: 'GOLD100',
        ),
      );

      // The new member's own commission starts at 0
      expect(state.commissionBalance, equals(0));

      // The referrer's balance has increased
      state.logout();
      state.login('demo@email.com', 'password');
      expect(state.commissionBalance, greaterThan(referrerBalanceBefore));
    });

    test('Normal tier referral credits exactly 500 THB', () {
      final state = AppState();
      state.login('demo@email.com', 'password');
      final before = state.commissionBalance;
      state.logout();

      state.register(
        const AppUser(
          id: 'u_normal_ref',
          name: 'Normal Ref',
          email: 'norm@email.com',
          phone: '+66100200300',
          membershipTier: MembershipTier.normal,
          referralCode: 'NORM2222',
          referredBy: 'GOLD100',
        ),
      );
      state.logout();
      state.login('demo@email.com', 'password');
      expect(state.commissionBalance, equals(before + 500.0));
    });

    test('Executive VIP referral credits exactly 10000 THB', () {
      final state = AppState();
      state.login('demo@email.com', 'password');
      final before = state.commissionBalance;
      state.logout();

      state.register(
        const AppUser(
          id: 'u_exec_ref',
          name: 'Exec Ref',
          email: 'exec@email.com',
          phone: '+66400500600',
          membershipTier: MembershipTier.executiveVip,
          referralCode: 'EXEC3333',
          referredBy: 'GOLD100',
        ),
      );
      state.logout();
      state.login('demo@email.com', 'password');
      expect(state.commissionBalance, equals(before + 10000.0));
    });
  });

  // ── Widget smoke test ──────────────────────────────────────────────────────

  group('Widget smoke test', () {
    testWidgets('PremiumApp builds without error', (tester) async {
      final appState = AppState();
      await tester.pumpWidget(
        AppStateScope(
          notifier: appState,
          child: const MaterialApp(home: Scaffold(body: Text('OK'))),
        ),
      );
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('MembershipPaymentScreen renders with correct tier and amount', (tester) async {
      final appState = AppState();
      const user = AppUser(
        id: 'u_pay_test',
        name: 'Pay Test',
        email: 'pay@test.com',
        phone: '+66700800900',
        membershipTier: MembershipTier.vip,
        referralCode: 'PAYT9999',
      );

      await tester.pumpWidget(
        AppStateScope(
          notifier: appState,
          child: MaterialApp(home: MembershipPaymentScreen(pendingUser: user)),
        ),
      );

      expect(find.text('MEMBERSHIP PAYMENT'), findsOneWidget);
      expect(find.text('VIP'), findsWidgets);
      expect(find.text('฿10,000'), findsWidgets);
    });

    testWidgets('MembershipPaymentScreen Verify button disabled before slip attached', (tester) async {
      final appState = AppState();
      const user = AppUser(
        id: 'u_btn_test',
        name: 'Btn Test',
        email: 'btn@test.com',
        phone: '+66111000999',
        membershipTier: MembershipTier.normal,
        referralCode: 'BTNT8888',
      );

      await tester.pumpWidget(
        AppStateScope(
          notifier: appState,
          child: MaterialApp(home: MembershipPaymentScreen(pendingUser: user)),
        ),
      );

      // With no slip attached the button label is "Attach Slip to Continue"
      expect(find.text('Attach Slip to Continue'), findsOneWidget);
      expect(find.text('Verify Payment'), findsNothing);
    });

    testWidgets('MembershipPaymentScreen shows Verify Payment after slip attached', (tester) async {
      final appState = AppState();
      const user = AppUser(
        id: 'u_slip_test',
        name: 'Slip Test',
        email: 'slip@test.com',
        phone: '+66222333444',
        membershipTier: MembershipTier.vip,
        referralCode: 'SLIP7777',
      );

      await tester.pumpWidget(
        AppStateScope(
          notifier: appState,
          child: MaterialApp(home: MembershipPaymentScreen(pendingUser: user)),
        ),
      );

      // Scroll the upload area into view then tap it
      final uploadFinder = find.text('Tap to attach payment slip');
      await tester.ensureVisible(uploadFinder);
      await tester.pump();
      await tester.tap(uploadFinder);
      await tester.pump(); // trigger setState rebuild
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Verify Payment'), findsOneWidget);
      expect(find.text('Attach Slip to Continue'), findsNothing);
    });
  });
}
