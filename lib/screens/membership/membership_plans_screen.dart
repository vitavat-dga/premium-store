import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../auth/register_screen.dart';

/// Polished comparison screen for all three membership tiers.
/// Accessible before registration (from Login) and from Profile.
class MembershipPlansScreen extends StatelessWidget {
  const MembershipPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.dependOnInheritedWidgetOfExactType<AppStateScope>()?.notifier;
    final isLoggedIn = state?.isLoggedIn ?? false;
    final currentTier = state?.currentUser?.membershipTier;

    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        title: const Text('MEMBERSHIP PLANS'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            goldDivider(),
            const SizedBox(height: 20),
            const Text(
              'Choose Your Membership',
              style: TextStyle(color: kTextPrimary, fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Every account can both buy and sell. '
              'Membership tier determines the price range you may list '
              'products at, which products you can browse and purchase, '
              'and the referral commission you earn when you invite others.',
              style: TextStyle(color: kTextSecondary, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Plan cards
            _PlanCard(
              tier: MembershipTier.normal,
              isCurrent: currentTier == MembershipTier.normal,
              isLoggedIn: isLoggedIn,
            ),
            const SizedBox(height: 16),
            _PlanCard(
              tier: MembershipTier.vip,
              isCurrent: currentTier == MembershipTier.vip,
              isHighlighted: true,
              isLoggedIn: isLoggedIn,
            ),
            const SizedBox(height: 16),
            _PlanCard(
              tier: MembershipTier.executiveVip,
              isCurrent: currentTier == MembershipTier.executiveVip,
              isLoggedIn: isLoggedIn,
            ),
            const SizedBox(height: 32),

            // Comparison table
            _ComparisonTable(),
            const SizedBox(height: 32),

            // Referral explainer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kDarkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGoldDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_outline, color: kGold, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'How Referrals Work',
                        style: TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '• Every registered member receives a unique referral code.\n'
                    '• Share your code with anyone considering joining.\n'
                    '• When they complete registration and membership payment '
                    'verification using your code, you earn exactly '
                    '10% of their membership fee as a direct commission.\n'
                    '• Commissions are credited only after the new member\'s '
                    'OTP and payment slip verification succeed.\n'
                    '• Commissions are direct only — there is no multi-level '
                    'or chain structure.\n'
                    '• Commission amounts: ฿500 (Normal), ฿1,000 (VIP), '
                    '฿10,000 (Executive VIP).',
                    style: TextStyle(color: kTextSecondary, fontSize: 13, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!isLoggedIn)
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text('Join Now — Register'),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final MembershipTier tier;
  final bool isCurrent;
  final bool isHighlighted;
  final bool isLoggedIn;

  const _PlanCard({required this.tier, this.isCurrent = false, this.isHighlighted = false, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final borderColor = isCurrent
        ? kGoldLight
        : isHighlighted
        ? kGold
        : kTextMuted;

    return Container(
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isCurrent ? 2 : 1),
        gradient: isHighlighted
            ? const LinearGradient(
                colors: [Color(0xFF1E1600), kDarkCard],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _tierIcon(tier),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tier.label,
                        style: TextStyle(
                          color: isHighlighted ? kGold : kTextPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('One-time registration fee', style: const TextStyle(color: kTextMuted, fontSize: 11)),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kGoldDark.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kGold),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(color: kGold, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              formatThb(tier.fee),
              style: const TextStyle(color: kGold, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _BulletRow(icon: Icons.sell_outlined, label: 'Sell', value: tier.sellRangeLabel),
            const SizedBox(height: 8),
            _BulletRow(icon: Icons.shopping_bag_outlined, label: 'Buy & Browse', value: tier.buyAccessLabel),
            const SizedBox(height: 8),
            _BulletRow(
              icon: Icons.people_outline,
              label: 'Referral Reward',
              value: '${formatThb(tier.referralCommission)} per invite',
              valueColor: kGoldLight,
            ),
            const SizedBox(height: 8),
            _BulletRow(icon: Icons.swap_horiz, label: 'Role', value: 'Buyer & Seller (same account)'),
          ],
        ),
      ),
    );
  }

  Widget _tierIcon(MembershipTier t) {
    final icons = {
      MembershipTier.normal: Icons.star_outline,
      MembershipTier.vip: Icons.diamond_outlined,
      MembershipTier.executiveVip: Icons.workspace_premium_outlined,
    };
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [kGoldLight, kGoldDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(icons[t], color: kBlack, size: 22),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _BulletRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kGold, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(color: kTextSecondary, fontSize: 13),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(color: valueColor ?? kTextPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1200),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Feature',
                    style: TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                _hdr('Normal'),
                _hdr('VIP'),
                _hdr('Exec VIP'),
              ],
            ),
          ),
          _row('Fee', '฿5,000', '฿10,000', '฿100,000'),
          _row('Sell Range', '≤฿9,000', '฿1k–90k', '฿1,000+'),
          _row('Buy Access', 'Normal', 'N + VIP', 'All'),
          _row('Referral\nReward', '฿500', '฿1,000', '฿10,000', isLast: true),
        ],
      ),
    );
  }

  Widget _hdr(String label) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _row(String feature, String n, String vip, String evip, {bool isLast = false}) {
    return Column(
      children: [
        const Divider(height: 1, color: Color(0xFF2A2A2A)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(feature, style: const TextStyle(color: kTextSecondary, fontSize: 12)),
              ),
              _cell(n),
              _cell(vip),
              _cell(evip),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cell(String value) {
    return Expanded(
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(color: kTextPrimary, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
