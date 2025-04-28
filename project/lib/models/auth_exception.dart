class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'An unknown error occurred']);

  factory AuthException.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const AuthException('Invalid email address');
      case 'user-disabled':
        return const AuthException('This account has been disabled');
      case 'user-not-found':
        return const AuthException('No account found for this email');
      case 'wrong-password':
        return const AuthException('Incorrect password');
      case 'email-already-in-use':
        return const AuthException('Email already in use');
      case 'operation-not-allowed':
        return const AuthException('Operation not allowed');
      case 'weak-password':
        return const AuthException('Password is too weak');
      default:
        return const AuthException();
    }
  }
}
