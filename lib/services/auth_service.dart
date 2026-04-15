import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign Up
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw "This email is already registered. Please login instead.";
      } else if (e.code == 'weak-password') {
        throw "Your password is too weak. Please use at least 6 characters.";
      } else if (e.code == 'invalid-email') {
        throw "Please enter a valid email address.";
      } else {
        throw "Registration failed. Please try again.";
      }
    } catch (e) {
      throw "An unexpected error occurred.";
    }
  }

  // Login
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw "You don't have an account yet! Please register first.";
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw "Incorrect email or password. Please try again.";
      } else if (e.code == 'invalid-email') {
        throw "Please enter a valid email address.";
      } else {
        throw "Login failed. Please try again.";
      }
    } catch (e) {
      throw "An unexpected error occurred.";
    }
  }

  // Logout
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  // Forgot Password / Reset Password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
