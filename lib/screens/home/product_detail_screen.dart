import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/product_image.dart';
import '../cart/cart_screen.dart';
import '../membership/membership_plans_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _imageIndex = 0;
  String? _selectedSize;
  int _quantity = 1;
  final PageController _pageCtrl = PageController();

  bool get _hasBytes => widget.product.imageBytes != null;

  int get _imageCount => _hasBytes ? 1 : (_urlImages.isEmpty ? 1 : _urlImages.length);

  List<String> get _urlImages {
    final imgs = widget.product.images;
    return imgs.isEmpty ? [widget.product.imageUrl] : imgs;
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _addToCart() {
    if (widget.product.sizes.isNotEmpty && _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a size first')));
      return;
    }
    AppStateScope.of(context).addToCart(widget.product, quantity: _quantity, variant: _selectedSize);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart'),
        backgroundColor: kDarkSurface,
        action: SnackBarAction(
          label: 'View',
          textColor: kGold,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
        ),
      ),
    );
  }

  void _buyNow() {
    if (widget.product.sizes.isNotEmpty && _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a size first')));
      return;
    }
    AppStateScope.of(context).addToCart(widget.product, quantity: _quantity, variant: _selectedSize);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final state = AppStateScope.of(context);
    final canAccess = state.canAccessProduct(product);
    final discount = product.originalPrice != null ? ((1 - product.price / product.originalPrice!) * 100).round() : 0;

    return Scaffold(
      backgroundColor: kDarkBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: kDarkBg, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios, color: kGold, size: 16),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: kDarkBg, shape: BoxShape.circle),
              child: const Icon(Icons.favorite_border, color: kGold, size: 20),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Image gallery
          SizedBox(
            height: 320,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageCtrl,
                  itemCount: _imageCount,
                  onPageChanged: (i) => setState(() => _imageIndex = i),
                  itemBuilder: (_, i) => Hero(
                    tag: i == 0 ? 'product-${product.id}' : 'product-${product.id}-$i',
                    child: ProductImage(
                      imageBytes: i == 0 ? widget.product.imageBytes : null,
                      imageUrl: _hasBytes ? '' : _urlImages[i],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 320,
                    ),
                  ),
                ),
                if (product.badge != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        product.badge!,
                        style: const TextStyle(color: kBlack, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ),
                if (_imageCount > 1)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Row(
                      children: List.generate(
                        _imageCount,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: _imageIndex == i ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _imageIndex == i ? kGold : kTextMuted,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Lock overlay on image if no access
                if (!canAccess)
                  Positioned.fill(
                    child: Container(
                      color: kBlack.withAlpha(178),
                      child: const Center(child: Icon(Icons.lock_outline, color: kGold, size: 60)),
                    ),
                  ),
              ],
            ),
          ),

          // Details
          Expanded(
            child: canAccess
                ? _AccessibleBody(
                    product: product,
                    discount: discount,
                    selectedSize: _selectedSize,
                    quantity: _quantity,
                    onSelectSize: (s) => setState(() => _selectedSize = s),
                    onQtyMinus: () => _quantity > 1 ? setState(() => _quantity--) : null,
                    onQtyPlus: () => setState(() => _quantity++),
                  )
                : _LockedBody(tier: product.requiredTier),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: const BoxDecoration(
              color: kBlack,
              border: Border(top: BorderSide(color: kDarkSurface)),
            ),
            child: canAccess
                ? Row(
                    children: [
                      Expanded(
                        child: GoldButton(
                          label: 'Add to Cart',
                          outlined: true,
                          icon: Icons.shopping_cart_outlined,
                          onPressed: _addToCart,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GoldButton(label: 'Buy Now', onPressed: _buyNow),
                      ),
                    ],
                  )
                : GoldButton(
                    label: 'View Membership Plans',
                    icon: Icons.workspace_premium_outlined,
                    onPressed: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipPlansScreen())),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AccessibleBody extends StatelessWidget {
  final Product product;
  final int discount;
  final String? selectedSize;
  final int quantity;
  final void Function(String) onSelectSize;
  final VoidCallback? onQtyMinus;
  final VoidCallback onQtyPlus;

  const _AccessibleBody({
    required this.product,
    required this.discount,
    required this.selectedSize,
    required this.quantity,
    required this.onSelectSize,
    required this.onQtyMinus,
    required this.onQtyPlus,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: kDarkSurface, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  product.category,
                  style: const TextStyle(color: kGold, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: const TextStyle(color: kTextPrimary, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  i < product.rating.floor()
                      ? Icons.star
                      : i < product.rating
                      ? Icons.star_half
                      : Icons.star_outline,
                  color: kGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${product.rating}',
                style: const TextStyle(color: kGold, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              Text('(${product.reviewCount} reviews)', style: const TextStyle(color: kTextSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatThb(product.price),
                style: const TextStyle(color: kGold, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              if (product.originalPrice != null) ...[
                Text(
                  formatThb(product.originalPrice!),
                  style: const TextStyle(
                    color: kTextMuted,
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: kTextMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF3D1200), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    '-$discount%',
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          if (product.sizes.isNotEmpty) ...[
            const Text(
              'Select Size',
              style: TextStyle(color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.sizes.map((s) {
                final sel = s == selectedSize;
                return GestureDetector(
                  onTap: () => onSelectSize(s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? kGold : kDarkSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: sel ? kGold : kTextMuted),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        color: sel ? kBlack : kTextPrimary,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              const Text(
                'Quantity',
                style: TextStyle(color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(color: kDarkSurface, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove, size: 18), color: kGold, onPressed: onQtyMinus),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        quantity.toString(),
                        style: const TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.add, size: 18), color: kGold, onPressed: onQtyPlus),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Product Description',
            style: TextStyle(color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(product.description, style: const TextStyle(color: kTextSecondary, fontSize: 14, height: 1.6)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _LockedBody extends StatelessWidget {
  final MembershipTier tier;
  const _LockedBody({required this.tier});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: Color(0xFF1A1200), shape: BoxShape.circle),
              child: const Icon(Icons.lock_outline, color: kGold, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Members Only',
              style: const TextStyle(color: kTextPrimary, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'This product is exclusively available to ${tier.label} members '
              'and above. Upgrade your membership to unlock access.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextSecondary, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
