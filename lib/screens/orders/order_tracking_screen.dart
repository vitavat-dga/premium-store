import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_image.dart';

class OrderTrackingScreen extends StatelessWidget {
  final Order order;
  const OrderTrackingScreen({super.key, required this.order});

  static const _steps = [
    (OrderStatus.pending, 'Order Placed', Icons.receipt_outlined),
    (OrderStatus.confirmed, 'Confirmed', Icons.check_circle_outline),
    (OrderStatus.shipped, 'In Transit', Icons.local_shipping_outlined),
    (OrderStatus.delivered, 'Delivered', Icons.home_outlined),
  ];

  int get _currentStep {
    switch (order.status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  String _dateString(DateTime dt) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final step = _currentStep;

    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        title: Text(order.id),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            if (order.status == OrderStatus.cancelled)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D0000),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text(
                      'Order Cancelled',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            else ...[
              // Tracking stepper
              const Text(
                'Delivery Status',
                style: TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ...List.generate(_steps.length, (i) {
                final (_, label, icon) = _steps[i];
                final isDone = i <= step;
                final isActive = i == step;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDone ? kGold : kDarkSurface,
                            shape: BoxShape.circle,
                            border: Border.all(color: isActive ? kGoldLight : kTextMuted, width: isActive ? 2 : 1),
                          ),
                          child: Icon(icon, size: 20, color: isDone ? kBlack : kTextMuted),
                        ),
                        if (i < _steps.length - 1)
                          Container(width: 2, height: 40, color: i < step ? kGold : kDarkSurface),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                color: isDone ? kTextPrimary : kTextMuted,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            if (isActive) const Text('Current status', style: TextStyle(color: kGold, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
            const SizedBox(height: 28),

            // Order details
            const Text(
              'Order Details',
              style: TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: kDarkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ProductImage(
                              imageBytes: item.product.imageBytes,
                              imageUrl: item.product.imageUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    color: kTextPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text('x${item.quantity}', style: const TextStyle(color: kTextSecondary, fontSize: 12)),
                              ],
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
                  _infoRow('Address', order.address),
                  const SizedBox(height: 6),
                  _infoRow('Payment', order.paymentMethod),
                  const SizedBox(height: 6),
                  _infoRow('Date', _dateString(order.createdAt)),
                  const Divider(color: kDarkSurface),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        formatThb(order.total),
                        style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(color: kTextSecondary, fontSize: 12)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: kTextPrimary, fontSize: 12)),
        ),
      ],
    );
  }
}
