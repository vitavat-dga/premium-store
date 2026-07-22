import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orangeAccent;
      case OrderStatus.confirmed:
        return Colors.blueAccent;
      case OrderStatus.shipped:
        return Colors.purpleAccent;
      case OrderStatus.delivered:
        return Colors.greenAccent;
      case OrderStatus.cancelled:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = AppStateScope.of(context).orders;

    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(title: const Text('My Orders')),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, color: kTextMuted, size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'No Orders Yet',
                    style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start shopping and place your first order',
                    style: TextStyle(color: kTextSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final order = orders[i];
                return GestureDetector(
                  onTap: () =>
                      Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order))),
                  child: Container(
                    decoration: BoxDecoration(
                      color: kDarkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.id,
                              style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(order.status).withAlpha(30),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _statusColor(order.status)),
                              ),
                              child: Text(
                                order.status.label,
                                style: TextStyle(
                                  color: _statusColor(order.status),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_dateString(order.createdAt)} · ${order.items.length} item(s)',
                          style: const TextStyle(color: kTextSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.items.map((i) => i.product.name).join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: kTextPrimary, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('via ${order.paymentMethod}', style: const TextStyle(color: kTextMuted, fontSize: 12)),
                            Text(
                              formatThb(order.total),
                              style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _dateString(DateTime dt) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}
