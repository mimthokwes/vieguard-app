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

  static GoogleSignIn get instance {
    if (_googleSignIn != null) return _googleSignIn!;

    final googleVieApp = dotenv.maybeGet('GOOGLE_VIE_APP');
    // Web client ID diperlukan di Android sebagai serverClientId agar Google menerbitkan idToken
    const webClientId = '964440457881-2h38if1b6eagqvhkicf10bjd9skn6j2p.apps.googleusercontent.com';

    _googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: webClientId,
      clientId: (!kIsWeb && Platform.isAndroid) ? null : googleVieApp,
    );

    return _googleSignIn!;
  }

  /// Membuka prompt login Google native (Google Play Services di Android).
  static Future<GoogleAuthResult?> signIn() async {
    try {
      final googleSignIn = instance;
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        // Pengguna membatalkan dialog login Google
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      return GoogleAuthResult(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
        email: account.email,
        name: account.displayName,
        picture: account.photoUrl,
      );
    } catch (e) {
      debugPrint('[GoogleAuthService] Native Google Sign-In error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await instance.signOut();
    } catch (_) {}
  }
}
