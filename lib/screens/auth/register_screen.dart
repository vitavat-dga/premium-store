import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/gold_button.dart';
import '../membership/membership_plans_screen.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  MembershipTier? _selectedTier;
  bool _referralChecked = false;
  bool _referralValid = false;
  String? _referrerName;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _referralCtrl.dispose();
    super.dispose();
  }

  void _checkReferralCode() {
    final code = _referralCtrl.text.trim();
    if (code.isEmpty) {
      setState(() {
        _referralChecked = false;
        _referralValid = false;
        _referrerName = null;
      });
      return;
    }
    final state = AppStateScope.of(context);
    final valid = state.isValidReferralCode(code);
    setState(() {
      _referralChecked = true;
      _referralValid = valid;
      _referrerName = valid ? state.getReferrerName(code) : null;
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTier == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a membership plan to continue')));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final userId = 'u_${DateTime.now().millisecondsSinceEpoch}';
    final referralCode = AppState.generateReferralCode(userId, _nameCtrl.text.trim());
    final referredBy = (_referralValid && _referralCtrl.text.trim().isNotEmpty)
        ? _referralCtrl.text.trim().toUpperCase()
        : null;

    final user = AppUser(
      id: userId,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      membershipTier: _selectedTier!,
      referralCode: referralCode,
      referredBy: referredBy,
    );

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OtpScreen(user: user)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              goldDivider(),
              const SizedBox(height: 24),

              // — Section: Account info ——————————————————————————————
              const Text(
                'Account Information',
                style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Fill in your details below. One account can both buy and sell.',
                style: TextStyle(color: kTextSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _field(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Name is required';
                        }
                        if (v.trim().length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _field(
                      controller: _emailCtrl,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@') || !v.contains('.')) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _field(
                      controller: _phoneCtrl,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Phone number is required';
                        }
                        if (v.length < 10) return 'Invalid phone number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePass,
                      style: const TextStyle(color: kTextPrimary),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: kTextMuted,
                          ),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password is required';
                        }
                        if (v.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscureConfirm,
                      style: const TextStyle(color: kTextPrimary),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: kTextMuted,
                          ),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password confirmation is required';
                        }
                        if (v != _passwordCtrl.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              // — Section: Membership plan ———————————————————————————
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Membership Plan',
                    style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipPlansScreen())),
                    child: const Text(
                      'View Plans',
                      style: TextStyle(
                        color: kGold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: kGold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Your tier controls which products you can list, browse, '
                'and buy. Upgrade later is not available in this demo.',
                style: TextStyle(color: kTextSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),

              ...MembershipTier.values.map(
                (tier) => _TierOption(
                  tier: tier,
                  isSelected: _selectedTier == tier,
                  onTap: () => setState(() => _selectedTier = tier),
                ),
              ),

              // — Section: Referral code ——————————————————————————————
              const SizedBox(height: 28),
              const Text(
                'Referral Code (Optional)',
                style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'If a friend invited you, enter their code here. '
                'They will receive a 10% commission of your membership fee.',
                style: TextStyle(color: kTextSecondary, fontSize: 12),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _referralCtrl,
                      style: const TextStyle(color: kTextPrimary, letterSpacing: 2, fontWeight: FontWeight.bold),
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Referral Code',
                        prefixIcon: const Icon(Icons.card_giftcard_outlined),
                        suffixIcon: _referralChecked
                            ? Icon(
                                _referralValid ? Icons.check_circle : Icons.cancel,
                                color: _referralValid ? Colors.greenAccent : Colors.redAccent,
                              )
                            : null,
                      ),
                      onChanged: (_) {
                        if (_referralChecked) {
                          setState(() {
                            _referralChecked = false;
                            _referralValid = false;
                            _referrerName = null;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _checkReferralCode,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kGold),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Validate',
                      style: TextStyle(color: kGold, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              if (_referralChecked) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _referralValid ? Colors.greenAccent.withAlpha(20) : Colors.redAccent.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _referralValid ? Colors.greenAccent : Colors.redAccent),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _referralValid ? Icons.check_circle : Icons.cancel,
                        color: _referralValid ? Colors.greenAccent : Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _referralValid
                              ? 'Valid code — ${_referrerName ?? "Referrer"} will receive ${_selectedTier != null ? formatThb(_selectedTier!.referralCommission) : "a commission"}'
                              : 'Invalid or unrecognised referral code. No commission will be awarded.',
                          style: TextStyle(color: _referralValid ? Colors.greenAccent : Colors.redAccent, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // — Section: Fee summary ————————————————————————————————
              if (_selectedTier != null) ...[
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1200),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kGoldDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Summary',
                        style: TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        label: '${_selectedTier!.label} Membership Fee',
                        value: formatThb(_selectedTier!.fee),
                      ),
                      if (_referralValid && _referrerName != null) ...[
                        const SizedBox(height: 6),
                        _SummaryRow(
                          label: '10% referral commission → $_referrerName',
                          value: formatThb(_selectedTier!.referralCommission),
                          valueColor: kTextSecondary,
                          subtitle: 'Deducted from your fee, paid to your referrer.',
                        ),
                      ],
                      const Divider(color: kGoldDark, height: 20),
                      _SummaryRow(label: 'You Pay', value: formatThb(_selectedTier!.fee), isBold: true),
                      const SizedBox(height: 6),
                      Text(
                        'Your referral reward per new Normal invite: '
                        '${formatThb(_selectedTier!.referralCommission)}',
                        style: const TextStyle(color: kTextMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              GoldButton(
                label: _loading ? 'Processing...' : 'Register & Verify OTP',
                onPressed: _loading ? null : _register,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(color: kTextSecondary)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(color: kGold, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: kTextPrimary),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: validator,
    );
  }
}

class _TierOption extends StatelessWidget {
  final MembershipTier tier;
  final bool isSelected;
  final VoidCallback onTap;

  const _TierOption({required this.tier, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E1600) : kDarkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? kGold : const Color(0xFF2A2A2A), width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? kGold : kTextMuted, width: 2),
                color: isSelected ? kGold : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, color: kBlack, size: 14) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tier.label,
                        style: TextStyle(
                          color: isSelected ? kGold : kTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatThb(tier.fee),
                        style: TextStyle(
                          color: isSelected ? kGold : kTextSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tier.sellRangeLabel}  •  ${tier.buyAccessLabel}',
                    style: const TextStyle(color: kTextMuted, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final String? subtitle;

  const _SummaryRow({required this.label, required this.value, this.isBold = false, this.valueColor, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isBold ? kTextPrimary : kTextSecondary,
                  fontSize: isBold ? 14 : 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? (isBold ? kGold : kTextPrimary),
                fontSize: isBold ? 15 : 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!, style: const TextStyle(color: kTextMuted, fontSize: 11)),
        ],
      ],
    );
  }
}
