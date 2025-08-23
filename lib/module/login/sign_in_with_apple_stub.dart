// Stub implementation for non-iOS platforms
class SignInWithApple {
  static Future<bool> isAvailable() async {
    return false;
  }
  
  static Future<AppleIDCredential> getAppleIDCredential({
    required List<AppleIDAuthorizationScopes> scopes,
  }) async {
    throw UnsupportedError('Apple Sign In is not supported on this platform');
  }
}

class AppleIDCredential {
  final String? email;
  final String? givenName;
  final String? familyName;
  
  AppleIDCredential({this.email, this.givenName, this.familyName});
}

enum AppleIDAuthorizationScopes {
  email,
  fullName,
}