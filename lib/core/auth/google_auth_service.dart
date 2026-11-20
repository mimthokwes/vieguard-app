import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthResult {
  final String? idToken;
  final String? accessToken;
  final String email;
  final String? name;
  final String? picture;

  GoogleAuthResult({
    this.idToken,
    this.accessToken,
    required this.email,
    this.name,
    this.picture,
  });
}

class GoogleAuthService {
  GoogleAuthService._();

  static const String webClientId = '964440457881-2h38if1b6eagqvhkicf10bjd9skn6j2p.apps.googleusercontent.com';

  /// Membuka prompt login Google native (Google Play Services di Android).
  /// Menggunakan strategi multi-tier: mencoba dengan serverClientId terlebih dahulu
  /// agar mendapatkan idToken, lalu otomatis fallback ke native Google Sign-In standar
  /// jika verifikasi serverClientId mengalami kendala di level platform.
  static Future<GoogleAuthResult?> signIn() async {
    // 1. Percobaan pertama: dengan serverClientId (untuk mendapatkan idToken resmi)
    try {
      final res = await _performSignIn(useServerClientId: true);
      if (res != null) return res;
      return null; // Pengguna membatalkan dialog
    } catch (e) {
      debugPrint('[GoogleAuthService] Sign-in dengan serverClientId terkendala: $e. Mencoba fallback native Google Sign-In...');
    }

    // 2. Percobaan kedua (Fallback): tanpa serverClientId agar dialog akun Google asli di HP tetap muncul
    try {
      final res = await _performSignIn(useServerClientId: false);
      if (res != null) return res;
      return null; // Pengguna membatalkan dialog
    } catch (e) {
      debugPrint('[GoogleAuthService] Fallback native Google Sign-In error: $e');
      rethrow;
    }
  }

  static Future<GoogleAuthResult?> _performSignIn({required bool useServerClientId}) async {
    final googleVieApp = dotenv.maybeGet('GOOGLE_VIE_APP');

    final googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: useServerClientId ? webClientId : null,
      clientId: (!kIsWeb && Platform.isAndroid) ? null : googleVieApp,
    );

    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }

    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account == null) {
      // Pengguna membatalkan dialog login Google
      return null;
    }

    String? idToken;
    String? accessToken;
    try {
      final GoogleSignInAuthentication auth = await account.authentication;
      idToken = auth.idToken;
      accessToken = auth.accessToken;
    } catch (e) {
      debugPrint('[GoogleAuthService] Gagal ekstraksi token auth: $e');
    }

    return GoogleAuthResult(
      idToken: idToken,
      accessToken: accessToken,
      email: account.email,
      name: account.displayName,
      picture: account.photoUrl,
    );
  }

  static Future<void> signOut() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: const ['email', 'profile']);
      await googleSignIn.signOut();
    } catch (_) {}
  }
}
