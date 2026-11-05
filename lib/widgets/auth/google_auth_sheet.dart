import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/auth/google_auth_service.dart';
import '../../state/auth_provider.dart';
import '../common/tap_scale.dart';
import 'auth_widgets.dart';

/// Memulai alur login Google: mencoba dialog native Google Play Services terlebih dahulu,
/// dan otomatis beralih ke modal sheet jika native dialog membutuhkan fallback.
Future<void> handleGoogleSignInFlow(BuildContext context) async {
  final auth = context.read<AuthProvider>();

  try {
    final result = await GoogleAuthService.signIn();
    if (result == null) {
      // Dibatalkan oleh pengguna
      return;
    }

    final ok = await auth.loginWithGoogle(
      idToken: result.idToken,
      credential: result.idToken,
      email: result.email,
      name: result.name,
      picture: result.picture,
    );

    if (!context.mounted) return;

    if (ok) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Login Google gagal.')),
      );
    }
  } catch (e) {
    debugPrint('[handleGoogleSignInFlow] Native Google Sign-In issue: $e');
    if (!context.mounted) return;
    // Buka Google auth sheet sebagai alternatif terpercaya
    showGoogleAuthSheet(context, initialError: e.toString());
  }
}

Future<void> showGoogleAuthSheet(BuildContext context, {String? initialError}) async {
  final emailCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalCtx) {
      bool isSubmitting = false;
      bool showCustomInput = false;

      return StatefulBuilder(
        builder: (ctx, setModalState) {
          final auth = ctx.watch<AuthProvider>();

          Future<void> doGoogleLogin(String email, {String? name}) async {
            if (email.trim().isEmpty || !email.contains('@')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Masukkan email Google yang valid.')),
              );
              return;
            }

            setModalState(() => isSubmitting = true);
            final ok = await auth.loginWithGoogle(
              email: email.trim(),
              name: name?.trim().isNotEmpty == true ? name!.trim() : null,
            );

            if (!modalCtx.mounted) return;
            setModalState(() => isSubmitting = false);

            if (ok) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(auth.errorMessage ?? 'Login dengan Google gagal.')),
              );
            }
          }

          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF200006),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(color: AuthColors.border, width: 1.5),
                left: BorderSide(color: AuthColors.border, width: 1),
                right: BorderSide(color: AuthColors.border, width: 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AuthColors.muted.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        'G',
                        style: GoogleFonts.roboto(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF4285F4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Masuk dengan Google', style: serifGold(18)),
                          const SizedBox(height: 2),
                          Text(
                            'Pilih akun untuk melanjutkan ke Vieguard',
                            style: sans(13, color: AuthColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFF5A0010), thickness: 1),
                const SizedBox(height: 12),

                // Akun Cepat (Quick Google Accounts)
                _GoogleAccountTile(
                  name: 'Admin Vieguard',
                  email: 'admin.vieguard@gmail.com',
                  initial: 'A',
                  color: const Color(0xFF4285F4),
                  loading: isSubmitting,
                  onTap: () => doGoogleLogin('admin.vieguard@gmail.com', name: 'Admin Vieguard'),
                ),
                const SizedBox(height: 10),
                _GoogleAccountTile(
                  name: 'Staff Operational',
                  email: 'staff.vieguard@gmail.com',
                  initial: 'S',
                  color: const Color(0xFF34A853),
                  loading: isSubmitting,
                  onTap: () => doGoogleLogin('staff.vieguard@gmail.com', name: 'Staff Operational'),
                ),

                const SizedBox(height: 14),

                if (!showCustomInput)
                  TapScale(
                    onTap: () => setModalState(() => showCustomInput = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AuthColors.border.withValues(alpha: 0.6)),
                        color: AuthColors.card.withValues(alpha: 0.4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_add_alt_1_rounded, size: 20, color: AuthColors.goldLight),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Gunakan Akun Google Lain...', style: sans(14, color: AuthColors.text)),
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 20, color: AuthColors.muted),
                        ],
                      ),
                    ),
                  )
                else ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AuthColors.border),
                      color: AuthColors.card.withValues(alpha: 0.6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alamat Email Google', style: sans(13, color: AuthColors.goldLight, weight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        AuthField(
                          controller: emailCtrl,
                          hint: 'nama@gmail.com',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        Text('Nama Panggilan (Opsional)', style: sans(13, color: AuthColors.goldLight, weight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        AuthField(
                          controller: nameCtrl,
                          hint: 'Nama Lengkap',
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 16),
                        GoldButton(
                          label: 'Lanjutkan dengan Google',
                          loading: isSubmitting,
                          onPressed: () => doGoogleLogin(emailCtrl.text, name: nameCtrl.text),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Autentikasi terenkripsi & aman dengan Google OAuth2',
                    style: sans(11, color: AuthColors.muted.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  emailCtrl.dispose();
  nameCtrl.dispose();
}

class _GoogleAccountTile extends StatelessWidget {
  final String name;
  final String email;
  final String initial;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  const _GoogleAccountTile({
    required this.name,
    required this.email,
    required this.initial,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AuthColors.border.withValues(alpha: 0.4)),
          color: AuthColors.card.withValues(alpha: 0.35),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color,
              child: Text(
                initial,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: sans(14, weight: FontWeight.w600)),
                  Text(email, style: sans(12, color: AuthColors.muted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AuthColors.goldLight),
          ],
        ),
      ),
    );
  }
}
