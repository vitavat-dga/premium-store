import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/product_image.dart';
import '../../widgets/section_header.dart';
import '../explore/explore_screen.dart';
import 'product_detail_screen.dart';
import 'seller_listing_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final user = state.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: kDarkBg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: _cardDecoration(),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.storefront_outlined, color: kGold, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Seller dashboard is available after sign in.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final listings = state.ownListings;
    final totalRevenue = listings.fold<double>(
      0,
      (sum, listing) => sum + listing.revenue,
    );
    final totalUnits = listings.fold<int>(
      0,
      (sum, listing) => sum + listing.unitsSold,
    );
    final activeListings = listings
        .where((listing) => listing.status == ListingStatus.active)
        .length;
    final avgPrice = listings.isEmpty
        ? 0.0
        : listings.fold<double>(0, (sum, listing) => sum + listing.price) /
              listings.length;
    final revenuePoints = _buildRevenuePoints(listings);
    final topListings = [...listings]
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return Scaffold(
      backgroundColor: kDarkBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openListingForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverAppBar(
            pinned: true,
            backgroundColor: kBlack,
            title: Text('SELLER DASHBOARD'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _SellerIdentityCard(user: user),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _TierLimitsCard(user: user),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _MetricsSection(
                totalRevenue: totalRevenue,
                totalUnits: totalUnits,
                activeListings: activeListings,
                avgPrice: avgPrice,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: SectionHeader(
                title: 'Revenue Overview',
                actionLabel: '6 Months',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _RevenueChart(points: revenuePoints),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: SectionHeader(title: 'Top Products', actionLabel: 'Top 3'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _TopProductsCard(listings: topListings.take(3).toList()),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: SectionHeader(
                title: 'My Listings',
                actionLabel: '${listings.length} items',
              ),
            ),
          ),
          if (listings.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _EmptyListingsCard(
                  onAdd: () => _openListingForm(context),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final listing = listings[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == listings.length - 1 ? 0 : 12,
                    ),
                    child: _ListingCard(
                      listing: listing,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailScreen(product: listing.toProduct()),
                        ),
                      ),
                      onEdit: () => _openListingForm(context, listing: listing),
                      onDelete: () => _deleteListing(context, listing),
                    ),
                  );
                }, childCount: listings.length),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              child: _ExploreShortcutCard(
                onExplore: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExploreScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openListingForm(
    BuildContext context, {
    SellerListing? listing,
  }) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SellerListingFormScreen(listing: listing),
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            listing == null
                ? 'Listing added successfully'
                : 'Listing updated successfully',
          ),
          backgroundColor: kDarkSurface,
        ),
      );
    }
  }

  Future<void> _deleteListing(
    BuildContext context,
    SellerListing listing,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: kDarkCard,
        title: const Text(
          'Delete listing?',
          style: TextStyle(color: kTextPrimary),
        ),
        content: Text(
          'Remove ${listing.name} from your seller dashboard?',
          style: const TextStyle(color: kTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      AppStateScope.of(context).deleteSellerListing(listing.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${listing.name} deleted'),
          backgroundColor: kDarkSurface,
        ),
      );
    }
  }

  static List<_RevenuePoint> _buildRevenuePoints(List<SellerListing> listings) {
    final now = DateTime.now();
    const monthLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return List.generate(6, (index) {
      final month = DateTime(now.year, now.month - (5 - index), 1);
      final revenue = listings.fold<double>(0, (sum, listing) {
        final monthlyRevenue = listing.salesHistory
            .where(
              (event) =>
                  event.date.year == month.year &&
                  event.date.month == month.month,
            )
            .fold<double>(0, (total, event) => total + event.revenue);
        return sum + monthlyRevenue;
      });
      return _RevenuePoint(
        label: monthLabels[month.month - 1],
        revenue: revenue,
      );
    });
  }
}

class _SellerIdentityCard extends StatelessWidget {
  final AppUser user;

  const _SellerIdentityCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [kGoldLight, kGoldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.storefront, color: kBlack, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Premium Seller',
                      style: TextStyle(
                        color: kTextSecondary,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _TierBadge(tier: user.membershipTier),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoPill(
                icon: Icons.badge_outlined,
                label: 'Member ID',
                value: user.id,
              ),
              _InfoPill(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
              ),
              _InfoPill(
                icon: Icons.call_outlined,
                label: 'Phone',
                value: user.phone,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TierLimitsCard extends StatelessWidget {
  final AppUser user;

  const _TierLimitsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selling Limits',
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user.membershipTier.sellRangeLabel,
            style: const TextStyle(
              color: kGoldLight,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.membershipTier.buyAccessLabel,
            style: const TextStyle(color: kTextSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kBlack,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.insights_outlined, color: kGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Use your ${user.membershipTier.label} tier to price listings confidently within the allowed range.',
                    style: const TextStyle(color: kTextSecondary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsSection extends StatelessWidget {
  final double totalRevenue;
  final int totalUnits;
  final int activeListings;
  final double avgPrice;

  const _MetricsSection({
    required this.totalRevenue,
    required this.totalUnits,
    required this.activeListings,
    required this.avgPrice,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final cardWidth = isWide
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: _MetricCard(
                title: 'Total Revenue',
                value: formatThb(totalRevenue),
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _MetricCard(
                title: 'Units Sold',
                value: '$totalUnits items',
                icon: Icons.inventory_2_outlined,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _MetricCard(
                title: 'Active Listings',
                value: '$activeListings live',
                icon: Icons.store_mall_directory_outlined,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _MetricCard(
                title: 'Average Price',
                value: formatThb(avgPrice),
                icon: Icons.sell_outlined,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kGold.withAlpha(36),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kGold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: kTextSecondary, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<_RevenuePoint> points;

  const _RevenueChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final maxRevenue = points.fold<double>(
      0,
      (max, point) => point.revenue > max ? point.revenue : max,
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue trend across your listings',
            style: TextStyle(color: kTextSecondary),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points.map((point) {
                final normalized = maxRevenue == 0
                    ? 0.0
                    : point.revenue / maxRevenue;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          point.revenue == 0 ? '฿0' : formatThb(point.revenue),
                          style: const TextStyle(
                            color: kTextMuted,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 150,
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            height: 24 + (126 * normalized),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [kGoldDark, kGoldLight],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF2A2A2A),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          point.label,
                          style: const TextStyle(
                            color: kTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopProductsCard extends StatelessWidget {
  final List<SellerListing> listings;

  const _TopProductsCard({required this.listings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: listings.isEmpty
          ? const Text(
              'No sales data yet. Publish products to start tracking revenue.',
              style: TextStyle(color: kTextSecondary, height: 1.5),
            )
          : Column(
              children: List.generate(listings.length, (index) {
                final listing = listings[index];
                return Container(
                  margin: EdgeInsets.only(
                    bottom: index == listings.length - 1 ? 0 : 12,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kBlack,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: kGold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            color: kBlack,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.name,
                              style: const TextStyle(
                                color: kTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${listing.unitsSold} sold · ${listing.category}',
                              style: const TextStyle(
                                color: kTextSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formatThb(listing.revenue),
                        style: const TextStyle(
                          color: kGoldLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final SellerListing listing;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ListingCard({
    required this.listing,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ProductImage(
                imageBytes: listing.imageBytes,
                imageUrl: listing.imageUrl,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          listing.name,
                          style: const TextStyle(
                            color: kTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(status: listing.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatThb(listing.price),
                    style: const TextStyle(
                      color: kGoldLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _StatChip(label: 'Stock', value: '${listing.stock}'),
                      _StatChip(label: 'Sold', value: '${listing.unitsSold}'),
                      _StatChip(
                        label: 'Tier',
                        value: listing.requiredTier.shortLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kGold,
                            side: const BorderSide(color: kGold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyListingsCard extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyListingsCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, color: kGold, size: 48),
          const SizedBox(height: 16),
          const Text(
            'No listings yet',
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first product listing to start building your premium storefront.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextSecondary, height: 1.5),
          ),
          const SizedBox(height: 18),
          GoldButton(
            label: 'Create Listing',
            onPressed: onAdd,
            icon: Icons.add,
          ),
        ],
      ),
    );
  }
}

class _ExploreShortcutCard extends StatelessWidget {
  final VoidCallback onExplore;

  const _ExploreShortcutCard({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGoldDark),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1600), kDarkCard],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_outlined, color: kGold, size: 32),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shop the Marketplace',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Browse products from other Hiso Elite sellers.',
                  style: TextStyle(color: kTextSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onExplore,
            tooltip: 'Open Explore',
            icon: const Icon(Icons.arrow_forward, color: kGold),
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
    Color color;
    switch (tier) {
      case MembershipTier.normal:
        color = kTextMuted;
        break;
      case MembershipTier.vip:
        color = kGold;
        break;
      case MembershipTier.executiveVip:
        color = kGoldLight;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        tier.shortLabel,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ListingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ListingStatus.active:
        color = const Color(0xFF4CAF50);
        break;
      case ListingStatus.draft:
        color = kGoldDark;
        break;
      case ListingStatus.outOfStock:
        color = Colors.redAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kGold, size: 18),
          const SizedBox(width: 8),
          Text('$label: $value', style: const TextStyle(color: kTextSecondary)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: kTextSecondary, fontSize: 12),
      ),
    );
  }
}

class _RevenuePoint {
  final String label;
  final double revenue;

  const _RevenuePoint({required this.label, required this.revenue});
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: kDarkCard,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFF2A2A2A)),
  );
}
