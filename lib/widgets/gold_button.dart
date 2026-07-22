import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final IconData? icon;

  const GoldButton({super.key, required this.label, required this.onPressed, this.outlined = false, this.icon});

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: icon != null ? Icon(icon, color: kGold) : const SizedBox.shrink(),
          label: Text(
            label,
            style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: kGold, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null ? kTextMuted : null,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: kBlack, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(color: kBlack, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: onPressed != null
                      ? const LinearGradient(
                          colors: [kGoldLight, kGold, kGoldDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(color: kBlack, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
      ),
    );
  }
}
