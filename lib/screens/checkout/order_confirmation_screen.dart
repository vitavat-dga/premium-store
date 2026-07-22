import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gold_button.dart';
import '../shell/main_shell.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String orderId;
  const OrderConfirmationScreen({super.key, required this.orderId});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.5, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) => Opacity(
                opacity: _opacity.value,
                child: Transform.scale(scale: _scale.value, child: child),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kGold, width: 3),
                      color: const Color(0xFF1A1400),
                    ),
                    child: const Icon(Icons.check_circle_outline, color: kGold, size: 64),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Order Placed!',
                    style: TextStyle(color: kTextPrimary, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Thank you for shopping\nat Premium Store',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kTextSecondary, fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: kDarkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kGold),
                    ),
                    child: Column(
                      children: [
                        const Text('Order ID', style: TextStyle(color: kTextSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          widget.orderId,
                          style: const TextStyle(
                            color: kGold,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your order will be processed shortly\nand shipped to your delivery address',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kTextMuted, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  GoldButton(
                    label: 'Back to Home',
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
                    },
                  ),
                  const SizedBox(height: 12),
                  GoldButton(
                    label: 'Track Order',
                    outlined: true,
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 3)),
                        (_) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
