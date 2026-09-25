import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myexpence/core/config/firebase_config.dart';
import 'package:myexpence/core/providers/core_providers.dart';
import 'package:myexpence/features/auth/domain/models/auth_user.dart';

class AuthNotifier extends StateNotifier<AuthUser> {
  static const String projectId = FirebaseConfig.projectId;
  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyUserUid = 'auth_user_uid';
  static const String _keyUserName = 'auth_user_name';

  final Ref? _ref;

  AuthNotifier([this._ref]) : super(AuthUser.anonymous()) {
    _loadAuthState();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    try {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          final userEmail = user.email ?? '';
          final userName = (user.displayName != null && user.displayName!.isNotEmpty)
              ? user.displayName!
              : (userEmail.contains('@') ? userEmail.split('@').first : 'Google User');

          if (userEmail.isNotEmpty) {
            _saveAndSetState(user.uid, userEmail, userName);
          }
        }
      });
    } catch (_) {}
  }

  Future<void> _loadAuthState() async {
    User? firebaseUser;
    try {
      firebaseUser = FirebaseAuth.instance.currentUser;
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();

    String? email = firebaseUser?.email ?? prefs.getString(_keyUserEmail);
    String? name = firebaseUser?.displayName ?? prefs.getString(_keyUserName);
    String uid = firebaseUser?.uid ?? prefs.getString(_keyUserUid) ?? '';
    bool isLoggedIn = firebaseUser != null || (prefs.getBool(_keyIsLoggedIn) ?? false);

    if (isLoggedIn && email != null && email.isNotEmpty) {
      final displayName = (name != null && name.isNotEmpty)
          ? name
          : (email.contains('@') ? email.split('@').first : 'Google User');

      state = AuthUser(
        uid: uid.isNotEmpty ? uid : 'google_${email.hashCode}',
        email: email,
        displayName: displayName,
        isLoggedIn: true,
      );
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        String uid = googleUser.id;
        String userEmail = googleUser.email;
        String userName = (googleUser.displayName != null && googleUser.displayName!.isNotEmpty)
            ? googleUser.displayName!
            : userEmail.split('@').first;

        try {
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          if (googleAuth.accessToken != null || googleAuth.idToken != null) {
            final OAuthCredential credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );

            final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
            if (userCredential.user != null) {
              uid = userCredential.user!.uid;
              userEmail = userCredential.user!.email ?? userEmail;
              if (userCredential.user!.displayName != null && userCredential.user!.displayName!.isNotEmpty) {
                userName = userCredential.user!.displayName!;
              }
            }
          }
        } catch (e) {
          debugPrint('Firebase Auth credential exchange warning: $e');
        }

        return await _saveAndSetState(uid, userEmail, userName);
      }
    } catch (e, stack) {
      debugPrint('Google Sign-In Exception: $e');
      debugPrint(stack.toString());
    }

    return false;
  }

  Future<bool> signInWithGoogleEmail(String email, {String? name}) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      return false;
    }

    final displayName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : trimmedEmail.split('@').first;
    final uid = 'google_${trimmedEmail.hashCode}';

    return await _saveAndSetState(uid, trimmedEmail, displayName);
  }

  Future<bool> _saveAndSetState(String uid, String email, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserUid, uid);
    await prefs.setString(_keyUserName, name);

    state = AuthUser(
      uid: uid,
      email: email,
      displayName: name,
      isLoggedIn: true,
    );

    return true;
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    state = AuthUser.anonymous();
  }

  Future<void> deleteAccount() async {
    try {
      // 1. Delete user from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    // 2. Wipe SQLite DB local data
    if (_ref != null) {
      try {
        final db = _ref.read(appDatabaseProvider);
        await db.clearAllData();
      } catch (_) {}
    }

    // 3. Clear all SharedPreferences data on device
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 4. Reset auth state
    state = AuthUser.anonymous();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthUser>((ref) {
  return AuthNotifier(ref);
});

