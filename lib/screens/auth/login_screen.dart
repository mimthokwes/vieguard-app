import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../widgets/auth/auth_widgets.dart';
import '../../widgets/auth/google_auth_sheet.dart';
import '../../widgets/common/tap_scale.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _remember = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final saved = await context.read<AuthProvider>().tokenStorage.readRememberedEmail();
      if (saved != null && mounted) setState(() => _emailCtrl.text = saved);
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final email = _emailCtrl.text.trim();
    await auth.tokenStorage.saveRememberedEmail(_remember ? email : null);
    final ok = await auth.login(email, _passwordCtrl.text);
    if (!mounted || ok) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Login gagal.')));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: AuthBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            const AuthLogo(subtitle: 'Selamat Datang!'),
            const SizedBox(height: 18),
            AuthCard(children: [
              const AuthLabel('Email'),
              AuthField(controller: _emailCtrl, hint: 'nama@email.com', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 18),
              const AuthLabel('Kata Sandi'),
              AuthField(controller: _passwordCtrl, hint: 'Masukkan kata sandi', icon: Icons.lock_outline_rounded, isPassword: true, onSubmitted: (_) => _submit()),
              const SizedBox(height: 16),
              Row(children: [
                TapScale(
                  onTap: () => setState(() => _remember = !_remember),
                  child: Row(children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _remember ? const Color(0xFF8C0A1E) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _remember ? const Color(0xFF8C0A1E) : AuthColors.border),
                      ),
                      child: _remember ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 10),
                    Text('Ingat Saya', style: sans(14)),
                  ]),
                ),
                const Spacer(),
                TapScale(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen(initialEmail: _emailCtrl.text.trim()))),
                  child: Text('Lupa kata sandi?', style: sans(14)),
                ),
              ]),
              const SizedBox(height: 24),
              GoldButton(label: 'Masuk', loading: auth.isLoading, onPressed: _submit),
              const SizedBox(height: 22),
              const OrDivider('ATAU LANJUTKAN DENGAN'),
              const SizedBox(height: 18),
              GoogleButton(
                loading: auth.isLoading,
                onTap: () => handleGoogleSignInFlow(context),
              ),
            ]),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Belum punya akun? ', style: sans(15)),
                TapScale(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: Text(
                    'Daftar Sekarang',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AuthColors.goldLight,
                      decoration: TextDecoration.underline,
                      decorationColor: AuthColors.goldLight,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
