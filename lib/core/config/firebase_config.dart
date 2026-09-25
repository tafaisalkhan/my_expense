class FirebaseConfig {
  static const String projectId = 'myexpenses-d3cb0';
  static const String clientEmail = 'firebase-adminsdk-fbsvc@myexpenses-d3cb0.iam.gserviceaccount.com';
  static const String clientId = '106822137642666279953';
  static const String privateKeyId = '5e9420aec652069368a9892adb3445225d39d1b4';
  static const String authUri = 'https://accounts.google.com/o/oauth2/auth';
  static const String tokenUri = 'https://oauth2.googleapis.com/token';
  static const String serviceAccountAssetPath = 'assets/config/firebase_service_account.json';

  static Map<String, dynamic> toMap() {
    return {
      'type': 'service_account',
      'project_id': projectId,
      'private_key_id': privateKeyId,
      'client_email': clientEmail,
      'client_id': clientId,
      'auth_uri': authUri,
      'token_uri': tokenUri,
    };
  }
}
