import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/gold_button.dart';
import '../membership/membership_payment_screen.dart';

class OtpScreen extends StatefulWidget {
  final AppUser user;

  const OtpScreen({super.key, required this.user});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrl = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focus = List.generate(6, (_) => FocusNode());
  int _countdown = 60;
  Timer? _timer;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _simulateAutoFill();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _simulateAutoFill() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    const otp = '123456';
    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      _ctrl[i].text = otp[i];
    }
    setState(() {});
  }

  void _resend() {
    if (_countdown > 0) return;
    setState(() => _countdown = 60);
    _startTimer();
    _simulateAutoFill();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A new OTP code has been sent')));
  }

  Future<void> _verify() async {
    final otp = _ctrl.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the 6-digit OTP code')));
      return;
    }
    setState(() => _verifying = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    // OTP success: navigate to payment gate; do NOT register yet.
    // AppState.register (and referral commission credit) happens only after
    // the user completes membership payment on MembershipPaymentScreen.
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => MembershipPaymentScreen(pendingUser: widget.user)));
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrl) {
      c.dispose();
    }
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(title: const Text('OTP Verification')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(color: kDarkSurface, shape: BoxShape.circle),
                  child: const Icon(Icons.verified_user_outlined, color: kGold, size: 36),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Verification Code',
                  style: TextStyle(color: kTextPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'An OTP code has been sent to\n${widget.user.phone}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: kTextSecondary, fontSize: 14),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (i) => SizedBox(
                    width: 44,
                    height: 52,
                    child: TextFormField(
                      controller: _ctrl[i],
                      focusNode: _focus[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(color: kGold, fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: kTextMuted),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: kTextMuted),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: kGold, width: 1.5),
                        ),
                        fillColor: _ctrl[i].text.isNotEmpty ? const Color(0xFF2A2216) : kDarkSurface,
                        filled: true,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 5) {
                          _focus[i + 1].requestFocus();
                        } else if (v.isEmpty && i > 0) {
                          _focus[i - 1].requestFocus();
                        }
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              GoldButton(label: _verifying ? 'Verifying...' : 'Verify', onPressed: _verifying ? null : _verify),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive a code? ", style: TextStyle(color: kTextSecondary, fontSize: 14)),
                  GestureDetector(
                    onTap: _countdown == 0 ? _resend : null,
                    child: Text(
                      _countdown > 0 ? 'Resend ($_countdown)' : 'Resend',
                      style: TextStyle(
                        color: _countdown == 0 ? kGold : kTextMuted,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
