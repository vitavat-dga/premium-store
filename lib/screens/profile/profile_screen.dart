import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/gold_button.dart';
import '../auth/login_screen.dart';
import '../membership/membership_plans_screen.dart';
import '../membership/referral_earnings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final user = state.currentUser;

    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              color: kBlack,
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [kGoldLight, kGoldDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: kGold, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(color: kBlack, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.name ?? 'User',
                      style: const TextStyle(color: kTextPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(user?.email ?? '', style: const TextStyle(color: kTextSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    if (user?.phone != null) Text(user!.phone, style: const TextStyle(color: kTextMuted, fontSize: 12)),
                    const SizedBox(height: 14),
                    // Membership tier badge
                    if (user != null) _TierBadge(tier: user.membershipTier),
                  ],
                ),
              ),
            ),

            goldDivider(),

            // Membership section
            _MenuSection(
              title: 'Membership',
              items: [
                _MenuItem(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Membership Plans',
                  onTap: () =>
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipPlansScreen())),
                  trailing: user != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1400),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kGoldDark),
                          ),
                          child: Text(
                            user.membershipTier.shortLabel,
                            style: const TextStyle(color: kGold, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                ),
                _MenuItem(
                  icon: Icons.people_outline,
                  label: 'Referral & Earnings',
                  onTap: () =>
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralEarningsScreen())),
                  trailing: state.referralHistory.isNotEmpty
                      ? Text(
                          formatThb(state.commissionBalance),
                          style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 12),
                        )
                      : null,
                ),
              ],
            ),

            // Account section
            _MenuSection(
              title: 'Account',
              items: [
                _MenuItem(
                  icon: Icons.person_outline,
                  label: 'Edit Profile',
                  onTap: () => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Profile editing feature coming soon'))),
                ),
                _MenuItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'My Orders',
                  onTap: () {},
                  trailing: Text(
                    '${state.orders.length}',
                    style: const TextStyle(color: kGold, fontWeight: FontWeight.bold),
                  ),
                ),
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  label: 'My Addresses',
                  onTap: () => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Address feature coming soon'))),
                ),
                _MenuItem(
                  icon: Icons.credit_card_outlined,
                  label: 'Payment Methods',
                  onTap: () => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Payment feature coming soon'))),
                ),
              ],
            ),

            _MenuSection(
              title: 'More',
              items: [
                _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Settings feature coming soon'))),
                ),
                _MenuItem(icon: Icons.help_outline, label: 'Help', onTap: () {}),
                _MenuItem(
                  icon: Icons.info_outline,
                  label: 'About App',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Premium Store',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2025 Premium Store',
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: GoldButton(
                label: 'Sign Out',
                outlined: true,
                icon: Icons.logout,
                onPressed: () => _showLogoutDialog(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kDarkCard,
        title: const Text('Sign Out?', style: TextStyle(color: kTextPrimary)),
        content: const Text(
          'Are you sure you want to sign out of this account?',
          style: TextStyle(color: kTextSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              state.logout();
              Navigator.of(
                context,
              ).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final MembershipTier tier;
  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    final icons = {
      MembershipTier.normal: Icons.star_outline,
      MembershipTier.vip: Icons.diamond_outlined,
      MembershipTier.executiveVip: Icons.workspace_premium_outlined,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1400),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGold),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icons[tier], color: kGold, size: 14),
          const SizedBox(width: 6),
          Text(
            '${tier.label.toUpperCase()} MEMBER',
            style: const TextStyle(color: kGold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: kTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: kDarkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              children: items
                  .asMap()
                  .entries
                  .map(
                    (e) => Column(
                      children: [
                        e.value,
                        if (e.key < items.length - 1) const Divider(height: 1, indent: 52, color: Color(0xFF2A2A2A)),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({required this.icon, required this.label, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: const Color(0xFF1A1400), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: kGold, size: 18),
      ),
      title: Text(label, style: const TextStyle(color: kTextPrimary, fontSize: 14)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: kTextMuted, size: 20),
      onTap: onTap,
      dense: true,
    );
  }
}
