import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/gold_button.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressCtrl = TextEditingController(text: '88 Sukhumvit Rd, Watthana, Bangkok 10110');
  String _paymentMethod = 'Bank Transfer';
  bool _placing = false;

  static const _paymentOptions = [
    ('Bank Transfer', Icons.account_balance_outlined),
    ('Credit Card', Icons.credit_card_outlined),
    ('E-Wallet', Icons.account_balance_wallet_outlined),
    ('Pay on Delivery (COD)', Icons.local_shipping_outlined),
  ];

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your shipping address')));
      return;
    }
    setState(() => _placing = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    AppStateScope.of(context).placeOrder(_addressCtrl.text.trim(), _paymentMethod);
    final orderId = AppStateScope.of(context).lastOrderId ?? '';
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => OrderConfirmationScreen(orderId: orderId)),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    const shippingFee = 250.0;

    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address
            _sectionTitle('Shipping Address'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _addressCtrl,
              maxLines: 3,
              style: const TextStyle(color: kTextPrimary),
              decoration: const InputDecoration(
                labelText: 'Full address',
                prefixIcon: Icon(Icons.location_on_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Payment
            _sectionTitle('Payment Method'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: kDarkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: RadioGroup<String>(
                groupValue: _paymentMethod,
                onChanged: (v) {
                  if (v != null) setState(() => _paymentMethod = v);
                },
                child: Column(
                  children: _paymentOptions.map((opt) {
                    final (label, icon) = opt;
                    final selected = label == _paymentMethod;
                    return ListTile(
                      dense: true,
                      leading: Radio<String>(value: label, activeColor: kGold),
                      title: Row(
                        children: [
                          Icon(icon, color: selected ? kGold : kTextSecondary, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            label,
                            style: TextStyle(
                              color: selected ? kGold : kTextPrimary,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => setState(() => _paymentMethod = label),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Order summary
            _sectionTitle('Order Summary'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: kDarkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...state.cart.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.product.name} x${item.quantity}',
                              style: const TextStyle(color: kTextSecondary, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            formatThb(item.product.price * item.quantity),
                            style: const TextStyle(color: kTextPrimary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: kDarkSurface),
                  _summaryRow('Subtotal', formatThb(state.cartTotal)),
                  const SizedBox(height: 4),
                  _summaryRow('Shipping', formatThb(shippingFee)),
                  const SizedBox(height: 8),
                  const Divider(color: kDarkSurface),
                  const SizedBox(height: 4),
                  _summaryRow('Total', formatThb(state.cartTotal + shippingFee), bold: true),
                ],
              ),
            ),
            const SizedBox(height: 32),

            GoldButton(
              label: _placing ? 'Processing Order...' : 'Place Order',
              onPressed: _placing ? null : _placeOrder,
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: bold ? kTextPrimary : kTextSecondary,
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: bold ? kGold : kTextPrimary,
            fontSize: bold ? 16 : 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
