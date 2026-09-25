class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isLoggedIn;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isLoggedIn = false,
  });

  factory AuthUser.anonymous() {
    return const AuthUser(
      uid: '',
      email: null,
      displayName: null,
      photoUrl: null,
      isLoggedIn: false,
    );
  }

  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isLoggedIn,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}
