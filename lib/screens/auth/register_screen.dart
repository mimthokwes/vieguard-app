import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../widgets/auth/auth_widgets.dart';
import '../../widgets/auth/google_auth_sheet.dart';
import '../../widgets/common/tap_scale.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmPasswordCtrl.text;

    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap minimal 2 karakter.')),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan alamat email yang valid.')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi minimal 6 karakter.')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: name,
      email: email,
      password: password,
      phone: phone.isNotEmpty ? phone : null,
    );

    if (!mounted) return;

    if (ok) {
      // Automatic navigation will happen via AuthProvider status change in RootNav
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Pendaftaran akun gagal.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: AuthBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            const AuthLogo(subtitle: 'Buat Akun Baru'),
            const SizedBox(height: 18),
            AuthCard(
              children: [
                const AuthLabel('Nama Lengkap'),
                AuthField(
                  controller: _nameCtrl,
                  hint: 'cth. Ahmad Fauzi',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),
                const AuthLabel('Alamat Email'),
                AuthField(
                  controller: _emailCtrl,
                  hint: 'nama@email.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                const AuthLabel('Nomor Telepon / WhatsApp'),
                AuthField(
                  controller: _phoneCtrl,
                  hint: '081234567890',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                const AuthLabel('Kata Sandi'),
                AuthField(
                  controller: _passwordCtrl,
                  hint: 'Minimal 6 karakter',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                const AuthLabel('Konfirmasi Kata Sandi'),
                AuthField(
                  controller: _confirmPasswordCtrl,
                  hint: 'Ulangi kata sandi',
                  icon: Icons.lock_reset_rounded,
                  isPassword: true,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                GoldButton(
                  label: 'Daftar Sekarang',
                  loading: auth.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 20),
                const OrDivider('ATAU DAFTAR DENGAN'),
                const SizedBox(height: 18),
                GoogleButton(
                  label: 'Daftar dengan Google',
                  loading: auth.isLoading,
                  onTap: () => handleGoogleSignInFlow(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sudah punya akun? ', style: sans(15)),
                TapScale(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Masuk',
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
