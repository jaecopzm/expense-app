import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isSignedIn => currentUser != null;

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResponse.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResponse.error(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResponse.error('An unexpected error occurred');
    }
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResponse.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResponse.error(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResponse.error('An unexpected error occurred');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AuthResponse> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResponse.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResponse.error(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResponse.error('An unexpected error occurred');
    }
  }

  Future<AuthResponse> updateDisplayName(String name) async {
    try {
      await currentUser?.updateDisplayName(name);
      await currentUser?.reload();
      return AuthResponse.success(_auth.currentUser);
    } catch (e) {
      return AuthResponse.error('Failed to update profile');
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}

class AuthResponse {
  final bool isSuccess;
  final User? user;
  final String? error;

  AuthResponse._(this.isSuccess, this.user, this.error);

  factory AuthResponse.success(User? user) => AuthResponse._(true, user, null);
  factory AuthResponse.error(String error) => AuthResponse._(false, null, error);
}
