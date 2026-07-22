import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';
import '../home/product_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Relevant';

  static const _categories = ['All', 'Clothing', 'Pants', 'Shoes', 'Accessories', 'Electronics'];

  static const _sortOptions = ['Relevant', 'Price: Low', 'Price: High', 'Rating'];

  List<Product> _filtered(List<Product> source) {
    var products = source.toList();

    if (_selectedCategory != 'All') {
      products = products.where((p) => p.category == _selectedCategory).toList();
    }

    if (_query.isNotEmpty) {
      products = products
          .where(
            (p) =>
                p.name.toLowerCase().contains(_query.toLowerCase()) ||
                p.category.toLowerCase().contains(_query.toLowerCase()),
          )
          .toList();
    }

    switch (_sortBy) {
      case 'Price: Low':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Rating':
        products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        break;
    }

    return products;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final products = _filtered(state.catalogProducts);
    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        title: const Text('Explore'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: kTextPrimary),
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: kTextMuted),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemCount: _categories.length,
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final sel = cat == _selectedCategory;
                        return FilterChip(
                          label: Text(cat),
                          selected: sel,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                          backgroundColor: kDarkSurface,
                          selectedColor: kGold,
                          checkmarkColor: kBlack,
                          labelStyle: TextStyle(
                            color: sel ? kBlack : kTextPrimary,
                            fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: sel ? kGold : kTextMuted),
                          ),
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.sort, color: kGold),
                      color: kDarkSurface,
                      initialValue: _sortBy,
                      onSelected: (v) => setState(() => _sortBy = v),
                      itemBuilder: (_) => _sortOptions
                          .map(
                            (s) => PopupMenuItem(
                              value: s,
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: s == _sortBy ? kGold : kTextPrimary,
                                  fontWeight: s == _sortBy ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text(
                  '${products.length} product(s) found',
                  style: const TextStyle(color: kTextSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, color: kTextMuted, size: 60),
                        const SizedBox(height: 12),
                        Text('No products found for "$_query"', style: const TextStyle(color: kTextSecondary)),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (ctx, constraints) {
                      final cols = constraints.maxWidth > 900
                          ? 4
                          : constraints.maxWidth > 600
                          ? 3
                          : 2;
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: products.length,
                        itemBuilder: (_, i) => ProductCard(
                          product: products[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProductDetailScreen(product: products[i])),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
