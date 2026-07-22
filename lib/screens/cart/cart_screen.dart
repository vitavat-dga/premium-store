import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/product_image.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final cart = state.cart;
    const shippingFee = 250.0;

    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        title: Text('Cart (${state.cartCount})'),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => _showClearDialog(context, state),
              child: const Text('Clear All', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, color: kTextMuted, size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'Cart is Empty',
                    style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Add products to your cart', style: TextStyle(color: kTextSecondary)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemCount: cart.length,
                    itemBuilder: (_, i) => _CartItemCard(
                      item: cart[i],
                      onRemove: () => state.removeFromCart(cart[i].product.id),
                      onQtyChanged: (q) => state.updateQuantity(cart[i].product.id, q),
                      formatPrice: formatThb,
                    ),
                  ),
                ),
                _OrderSummary(
                  subtotal: state.cartTotal,
                  shippingFee: shippingFee,
                  formatPrice: formatThb,
                  onCheckout: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                ),
              ],
            ),
    );
  }

  void _showClearDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kDarkCard,
        title: const Text('Clear All?', style: TextStyle(color: kTextPrimary)),
        content: const Text('All items in your cart will be removed.', style: TextStyle(color: kTextSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              state.clearCart();
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final void Function(int) onQtyChanged;
  final String Function(double) formatPrice;

  const _CartItemCard({
    required this.item,
    required this.onRemove,
    required this.onQtyChanged,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: ProductImage(
              imageBytes: item.product.imageBytes,
              imageUrl: item.product.imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: kTextPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      GestureDetector(
                        onTap: onRemove,
                        child: const Icon(Icons.close, color: kTextMuted, size: 18),
                      ),
                    ],
                  ),
                  if (item.variant != null) ...[
                    const SizedBox(height: 2),
                    Text('Size: ${item.variant}', style: const TextStyle(color: kTextSecondary, fontSize: 11)),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatPrice(item.product.price),
                        style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Row(
                        children: [
                          _QtyButton(icon: Icons.remove, onTap: () => onQtyChanged(item.quantity - 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              item.quantity.toString(),
                              style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          _QtyButton(icon: Icons.add, onTap: () => onQtyChanged(item.quantity + 1)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: kDarkSurface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kTextMuted),
        ),
        child: Icon(icon, color: kGold, size: 14),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final double subtotal;
  final double shippingFee;
  final String Function(double) formatPrice;
  final VoidCallback onCheckout;

  const _OrderSummary({
    required this.subtotal,
    required this.shippingFee,
    required this.formatPrice,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        color: kBlack,
        border: Border(top: BorderSide(color: kDarkSurface)),
      ),
      child: Column(
        children: [
          _row('Subtotal', formatPrice(subtotal)),
          const SizedBox(height: 6),
          _row('Shipping', formatPrice(shippingFee)),
          const SizedBox(height: 8),
          Container(height: 1, color: kDarkSurface),
          const SizedBox(height: 8),
          _row('Total', formatPrice(subtotal + shippingFee), isBold: true, valueColor: kGold),
          const SizedBox(height: 16),
          GoldButton(label: 'Checkout', onPressed: onCheckout),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? kTextPrimary : kTextSecondary,
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? kTextPrimary,
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
