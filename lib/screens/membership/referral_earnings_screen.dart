import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

/// Shows the current user''s referral code, commission balance, and history.
class ReferralEarningsScreen extends StatelessWidget {
  const ReferralEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final user = state.currentUser;
    if (user == null) return const SizedBox.shrink();

    final history = state.referralHistory;
    final balance = state.commissionBalance;

    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        title: const Text('REFERRAL & EARNINGS'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            goldDivider(),
            const SizedBox(height: 20),

            // Referral code card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kDarkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kGold),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1600), kDarkCard],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'YOUR REFERRAL CODE',
                    style: TextStyle(
                      color: kTextSecondary,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.referralCode,
                        style: const TextStyle(
                          color: kGold,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: user.referralCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Code "${user.referralCode}" copied to clipboard'),
                              backgroundColor: kDarkSurface,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kDarkSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kGoldDark),
                          ),
                          child: const Icon(Icons.copy_outlined, color: kGold, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Share this code with others. When they complete OTP and '
                    'membership payment verification using your code, '
                    'your direct commission is credited.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kTextMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Commission Balance',
                    value: formatThb(balance),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Total Referrals',
                    value: history.length.toString(),
                    icon: Icons.people_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Commission explanation
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kDarkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: kGold, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'How Commission Works',
                        style: TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You earn exactly 10% of the membership fee paid by each '
                    'person who completes OTP and membership payment '
                    'verification using your referral code. '
                    'Commission is direct only — you are rewarded for '
                    'members you personally invite, not for their invitees.\n\n'
                    'Commission is credited only after the new member\'s '
                    'payment slip verification succeeds.\n\n'
                    'Commission by tier:\n'
                    '  • Normal (฿5,000 fee) → you earn ฿500\n'
                    '  • VIP (฿10,000 fee) → you earn ฿1,000\n'
                    '  • Executive VIP (฿100,000 fee) → you earn ฿10,000\n\n'
                    'Referral income depends entirely on who you invite and '
                    'which tier they choose. No income is guaranteed.',
                    style: const TextStyle(color: kTextSecondary, fontSize: 12, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Referral History',
                  style: TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('${history.length} member(s)', style: const TextStyle(color: kTextSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),

            if (history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.people_outline, color: kTextMuted, size: 50),
                      const SizedBox(height: 12),
                      const Text(
                        'No referrals yet',
                        style: TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Share your code "${user.referralCode}" to start earning',
                        style: const TextStyle(color: kTextSecondary, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: kDarkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Column(
                  children: history
                      .asMap()
                      .entries
                      .map(
                        (e) => Column(
                          children: [
                            if (e.key > 0) const Divider(height: 1, color: Color(0xFF2A2A2A)),
                            _ReferralRow(record: e.value),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kGold, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: kGold, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: kTextSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ReferralRow extends StatelessWidget {
  final ReferralRecord record;
  const _ReferralRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final tierColor = _tierColor(record.refereeTier);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1400),
              shape: BoxShape.circle,
              border: Border.all(color: kGoldDark),
            ),
            child: Center(
              child: Text(
                record.refereeName.isNotEmpty ? record.refereeName[0].toUpperCase() : '?',
                style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.refereeName,
                  style: const TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tierColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: tierColor),
                      ),
                      child: Text(
                        record.refereeTier.shortLabel,
                        style: TextStyle(color: tierColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_dateStr(record.joinedAt), style: const TextStyle(color: kTextMuted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '+${formatThb(record.commissionEarned)}',
            style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Color _tierColor(MembershipTier tier) {
    switch (tier) {
      case MembershipTier.normal:
        return Colors.blueAccent;
      case MembershipTier.vip:
        return kGold;
      case MembershipTier.executiveVip:
        return Colors.purpleAccent;
    }
  }

  String _dateStr(DateTime dt) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}
