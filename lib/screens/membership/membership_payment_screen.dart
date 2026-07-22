import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/gold_button.dart';
import '../shell/main_shell.dart';

// ── Mock bank details (demo values — not real) ────────────────────────────────
const _kBankLabel = 'Kasikornbank (KBank)';
const _kAccountHolder = 'PREMIUM STORE DEMO';
const _kAccountNumber = '123-4-56789-0';
// ─────────────────────────────────────────────────────────────────────────────

/// Payment-gate screen shown immediately after OTP success.
///
/// The user cannot enter the app until:
///   1. A payment slip is attached (mock file-picker simulation).
///   2. The "Verify Payment" button is pressed and the simulated check passes.
///   3. [AppState.register] is called, which credits the referral commission.
///
/// ⚠️  PROTOTYPE ONLY — no real bank connection or slip verification exists.
class MembershipPaymentScreen extends StatefulWidget {
  final AppUser pendingUser;

  const MembershipPaymentScreen({super.key, required this.pendingUser});

  @override
  State<MembershipPaymentScreen> createState() => _MembershipPaymentScreenState();
}

class _MembershipPaymentScreenState extends State<MembershipPaymentScreen> {
  String? _attachedFilename;
  bool _submitting = false;
  bool _submitted = false; // prevents double registration/commission credit

  static const _demoFiles = [
    'transfer_slip.jpg',
    'kbank_receipt_2025.png',
    'payment_proof.pdf',
    'screenshot_20250723.jpg',
  ];
  int _demoFileIndex = 0;

  void _pickSlip() {
    if (_submitting) return;
    setState(() {
      _attachedFilename = _demoFiles[_demoFileIndex % _demoFiles.length];
      _demoFileIndex++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Slip attached: $_attachedFilename'),
        backgroundColor: kDarkSurface,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeSlip() {
    if (_submitting) return;
    setState(() => _attachedFilename = null);
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: kDarkSurface,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _verifyPayment() async {
    if (_attachedFilename == null || _submitting || _submitted) return;
    setState(() => _submitting = true);

    // Simulate async verification delay
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    if (_submitted) return; // double-tap safety guard
    _submitted = true;

    // Register user — this is the single place that credits referral commission.
    AppStateScope.of(context).register(widget.pendingUser);

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SuccessDialog(user: widget.pendingUser),
    );

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.pendingUser;
    final tier = user.membershipTier;
    final hasSlip = _attachedFilename != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 640 ? 560.0 : double.infinity;

    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: kDarkBg,
        appBar: AppBar(
          title: const Text('MEMBERSHIP PAYMENT'),
          leading: _submitting
              ? const SizedBox.shrink()
              : IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
        ),
        body: SafeArea(
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DemoBanner(),
                    const SizedBox(height: 20),
                    goldDivider(),
                    const SizedBox(height: 20),

                    // Selected membership tier & amount
                    const _SectionHeader(icon: Icons.workspace_premium_outlined, label: 'Your Selected Membership'),
                    const SizedBox(height: 12),
                    _TierSummaryCard(user: user, tier: tier),
                    const SizedBox(height: 24),

                    // Bank transfer details
                    const _SectionHeader(icon: Icons.account_balance_outlined, label: 'Transfer To'),
                    const SizedBox(height: 12),
                    _BankDetailsCard(onCopy: _copyToClipboard),
                    const SizedBox(height: 24),

                    // Slip upload
                    const _SectionHeader(icon: Icons.upload_file_outlined, label: 'Attach Payment Slip'),
                    const SizedBox(height: 12),
                    _SlipUploadArea(
                      filename: _attachedFilename,
                      submitting: _submitting,
                      onPick: _pickSlip,
                      onRemove: _removeSlip,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '⚠️  Slip upload & verification is simulated for this '
                      'prototype. No real file is transferred or checked.',
                      style: TextStyle(color: kTextMuted, fontSize: 11, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Referral commission note (shown when referred)
                    if (user.referredBy != null) ...[_ReferralNote(tier: tier), const SizedBox(height: 24)],

                    // Verify button / progress
                    if (_submitting)
                      const _VerifyingIndicator()
                    else
                      GoldButton(
                        label: hasSlip ? 'Verify Payment' : 'Attach Slip to Continue',
                        onPressed: hasSlip ? _verifyPayment : null,
                        icon: hasSlip ? Icons.verified_outlined : null,
                      ),
                    if (!hasSlip && !_submitting) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'You must attach a payment slip before proceeding.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kTextMuted, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _DemoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0F00),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kGoldDark),
      ),
      child: const Row(
        children: [
          Icon(Icons.science_outlined, color: kGold, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'PROTOTYPE DEMO — Bank details below are mock/fictitious. '
              'No real payment is processed.',
              style: TextStyle(color: kGoldDark, fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: kGold, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
        ),
      ],
    );
  }
}

class _TierSummaryCard extends StatelessWidget {
  final AppUser user;
  final MembershipTier tier;

  const _TierSummaryCard({required this.user, required this.tier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGold, width: 1.5),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1600), kDarkCard],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [kGoldLight, kGoldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(_tierIcon(tier), color: kBlack, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.label,
                  style: const TextStyle(color: kGold, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                const Text('One-time membership fee', style: TextStyle(color: kTextMuted, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  user.name,
                  style: const TextStyle(color: kTextSecondary, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Amount Due', style: TextStyle(color: kTextMuted, fontSize: 10)),
              const SizedBox(height: 4),
              Text(
                formatThb(tier.fee),
                style: const TextStyle(color: kGoldLight, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text('THB', style: TextStyle(color: kTextMuted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  IconData _tierIcon(MembershipTier t) {
    switch (t) {
      case MembershipTier.normal:
        return Icons.star_outline;
      case MembershipTier.vip:
        return Icons.diamond_outlined;
      case MembershipTier.executiveVip:
        return Icons.workspace_premium_outlined;
    }
  }
}

class _BankDetailsCard extends StatelessWidget {
  final void Function(String text, String label) onCopy;

  const _BankDetailsCard({required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF007B40), borderRadius: BorderRadius.circular(8)),
                child: const Text(
                  'K',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _kBankLabel,
                      style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text('[DEMO — not a real bank account]', style: TextStyle(color: kTextMuted, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          const SizedBox(height: 14),
          _DetailRow(
            label: 'Account Holder',
            value: _kAccountHolder,
            onCopy: () => onCopy(_kAccountHolder, 'Account holder name'),
          ),
          const SizedBox(height: 14),
          _DetailRow(
            label: 'Account Number',
            value: _kAccountNumber,
            valueStyle: const TextStyle(color: kGold, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
            onCopy: () => onCopy(_kAccountNumber, 'Account number'),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: kTextMuted, size: 13),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Transfer exactly the fee amount shown above. '
                    'Include your full name in the transfer reference.',
                    style: TextStyle(color: kTextMuted, fontSize: 11, height: 1.4),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final VoidCallback onCopy;

  const _DetailRow({required this.label, required this.value, this.valueStyle, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: kTextMuted, fontSize: 11)),
              const SizedBox(height: 4),
              Text(
                value,
                style: valueStyle ?? const TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onCopy,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kDarkSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kGoldDark),
            ),
            child: const Icon(Icons.copy_outlined, color: kGold, size: 16),
          ),
        ),
      ],
    );
  }
}

class _SlipUploadArea extends StatelessWidget {
  final String? filename;
  final bool submitting;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _SlipUploadArea({
    required this.filename,
    required this.submitting,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (filename != null) {
      return _AttachedSlip(filename: filename!, submitting: submitting, onRemove: onRemove);
    }
    return GestureDetector(
      onTap: submitting ? null : onPick,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: kDarkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kGoldDark, width: 1.5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, color: kGold, size: 36),
            SizedBox(height: 8),
            Text(
              'Tap to attach payment slip',
              style: TextStyle(color: kTextSecondary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text('JPG, PNG or PDF', style: TextStyle(color: kTextMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _AttachedSlip extends StatelessWidget {
  final String filename;
  final bool submitting;
  final VoidCallback onRemove;

  const _AttachedSlip({required this.filename, required this.submitting, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final ext = filename.toLowerCase();
    final isImage = ext.endsWith('.jpg') || ext.endsWith('.png') || ext.endsWith('.jpeg');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1A0D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.greenAccent.shade700, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0A1A0A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.greenAccent.shade700),
            ),
            child: Icon(
              isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined,
              color: Colors.greenAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  style: const TextStyle(color: kTextPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Slip attached — ready for verification',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 11),
                ),
              ],
            ),
          ),
          if (!submitting)
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: kDarkSurface, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.close, color: kTextMuted, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReferralNote extends StatelessWidget {
  final MembershipTier tier;

  const _ReferralNote({required this.tier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1200),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kGoldDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.people_outline, color: kGold, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Once your payment is verified, your inviter earns a direct '
              'referral commission of ${formatThb(tier.referralCommission)} '
              '(10% of your ${formatThb(tier.fee)} membership fee).',
              style: const TextStyle(color: kTextSecondary, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifyingIndicator extends StatelessWidget {
  const _VerifyingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        LinearProgressIndicator(color: kGold, backgroundColor: kDarkSurface),
        SizedBox(height: 14),
        Text(
          'Verifying payment slip…',
          textAlign: TextAlign.center,
          style: TextStyle(color: kTextSecondary, fontSize: 13),
        ),
      ],
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final AppUser user;

  const _SuccessDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kDarkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: kGold, size: 64),
            const SizedBox(height: 20),
            const Text(
              'Payment Verified!',
              style: TextStyle(color: kTextPrimary, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome to Premium Store,\n${user.name}!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextSecondary, fontSize: 14),
            ),
            if (user.referredBy != null) ...[
              const SizedBox(height: 10),
              const Text(
                'Referral commission has been credited to your inviter.',
                textAlign: TextAlign.center,
                style: TextStyle(color: kGoldDark, fontSize: 12),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Enter App')),
            ),
          ],
        ),
      ),
    );
  }
}
