import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'product_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final canAccess = state.canAccessProduct(product);

    return GestureDetector(
      onTap: canAccess ? onTap : () => _showLockedSnackBar(context),
      child: Container(
        decoration: BoxDecoration(
          color: kDarkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: canAccess ? const Color(0xFF2A2A2A) : kTextMuted),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Hero(
                        tag: 'product-${product.id}',
                        child: SizedBox.expand(
                          child: ProductImage(
                            imageBytes: product.imageBytes,
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (product.badge != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              product.badge!,
                              style: const TextStyle(
                                color: kBlack,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: canAccess ? kTextPrimary : kTextMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: kGold, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toString(),
                              style: const TextStyle(color: kTextSecondary, fontSize: 11),
                            ),
                            const SizedBox(width: 4),
                            Text('(${product.reviewCount})', style: const TextStyle(color: kTextMuted, fontSize: 10)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatThb(product.price),
                                    style: TextStyle(
                                      color: canAccess ? kGold : kTextMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (product.originalPrice != null)
                                    Text(
                                      formatThb(product.originalPrice!),
                                      style: const TextStyle(
                                        color: kTextMuted,
                                        fontSize: 10,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: kTextMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (canAccess)
                              GestureDetector(
                                onTap: () {
                                  AppStateScope.of(context).addToCart(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} added to cart'),
                                      backgroundColor: kDarkSurface,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.add_shopping_cart, color: kBlack, size: 14),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Lock overlay for inaccessible products
            if (!canAccess)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(color: kBlack.withAlpha(178), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline, color: kGold, size: 28),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Requires ${product.requiredTier.label} Membership',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: kGold, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLockedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('This product requires ${product.requiredTier.label} membership.'),
        backgroundColor: kDarkSurface,
        action: SnackBarAction(label: 'Plans', textColor: kGold, onPressed: () {}),
      ),
    );
  }
}
