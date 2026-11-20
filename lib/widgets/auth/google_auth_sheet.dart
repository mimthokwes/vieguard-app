import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/auth/google_auth_service.dart';
import '../../state/auth_provider.dart';

/// Menampilkan notifikasi error state yang elegan dan konsisten dengan tema VieGuard
void showAuthErrorBanner(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        backgroundColor: const Color(0xFF2E050D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFFC93B4E).withValues(alpha: 0.8),
            width: 1.2,
          ),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF5A0C1A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFFF8B94),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kendala Autentikasi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF8B94),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFFFF4E0),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
}

/// Memulai alur login Google: memanggil dialog native Google Play Services bawaan.
/// Mengirim payload akun asli pengguna ke endpoint backend (/api/v0/mobile/auth/google).
Future<void> handleGoogleSignInFlow(BuildContext context) async {
  final auth = context.read<AuthProvider>();

  try {
    debugPrint('[handleGoogleSignInFlow] Memulai otentikasi Google...');
    final result = await GoogleAuthService.signIn();
    if (result == null) {
      debugPrint('[handleGoogleSignInFlow] Otentikasi dibatalkan pengguna.');
      return;
    }

    debugPrint('[handleGoogleSignInFlow] Berhasil memilih akun: ${result.email}. Mengirim ke backend...');
    final ok = await auth.loginWithGoogle(
      idToken: result.idToken,
      credential: result.idToken,
      email: result.email,
      name: result.name,
      picture: result.picture,
    );

    if (!context.mounted) return;

    if (ok) {
      debugPrint('[handleGoogleSignInFlow] Login Google berhasil di backend!');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      debugPrint('[handleGoogleSignInFlow] Backend merespons kegagalan: ${auth.errorMessage}');
      showAuthErrorBanner(
        context,
        auth.errorMessage ?? 'Backend menolak autentikasi. Silakan periksa log server.',
      );
    }
  } catch (e) {
    debugPrint('[handleGoogleSignInFlow] Native Google Sign-In error: $e');
    if (!context.mounted) return;
    showAuthErrorBanner(
      context,
      'Kendala Google Sign-In: $e',
    );
  }
}
