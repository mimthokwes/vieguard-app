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

  static GoogleSignIn? _googleSignIn;

  /// Inisialisasi GoogleSignIn langsung menggunakan Google Play Services bawaan perangkat.
  /// Tidak membutuhkan serverClientId yang rentan bentrok, dan clientId diatur null di Android.
  static GoogleSignIn get instance {
    if (_googleSignIn != null) return _googleSignIn!;

    final googleVieApp = dotenv.maybeGet('GOOGLE_VIE_APP')?.trim();

    _googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: (googleVieApp != null && googleVieApp.isNotEmpty) ? googleVieApp : null,
      clientId: (!kIsWeb && Platform.isAndroid) ? null : googleVieApp,
    );

    return _googleSignIn!;
  }

  /// Membuka dialog native Google Sign-In bawaan perangkat (Google Play Services).
  /// Mengambil data akun asli pengguna (email, nama lengkap, dan foto profil).
  static Future<GoogleAuthResult?> signIn() async {
    final googleSignIn = instance;

    // Reset status login GoogleSignIn sebelumnya agar pengguna selalu disajikan pilihan akun
    try {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (e) {
      debugPrint('[GoogleAuthService] Reset sesi login sebelumnya: $e');
    }

    // Tampilkan dialog pemilihan akun bawaan perangkat
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account == null) {
      // Pengguna membatalkan dialog secara sengaja (menutup dialog)
      return null;
    }

    String? idToken;
    String? accessToken;
    try {
      final GoogleSignInAuthentication auth = await account.authentication;
      idToken = auth.idToken;
      accessToken = auth.accessToken;
    } catch (e) {
      debugPrint('[GoogleAuthService] Ekstraksi token auth opsional dilewati: $e');
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
      await instance.signOut();
    } catch (_) {}
  }
}
