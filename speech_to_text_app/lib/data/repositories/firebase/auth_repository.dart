import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text_app/utilities/constants/app_constants.dart';

abstract class AuthRepository {
  Stream<User?> get user;
  String getCurrentUserId();
  Future<void> login(String email, String password);
  Future<void> register(String email, String password);
  Future<void> logOut();
  Future<void> changeDisplayName(String displayName);
  Future<void> changePassword(String password);
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  @override
  String getCurrentUserId() {
    return _firebaseAuth.currentUser!.uid;
  }

  @override
  Future<void> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print("Error code: ${e.code}");
      if (e.code == AppConstants.userNotFound) {
        throw Exception('No user found for that email.');
      } else if (e.code == AppConstants.wrongPassword) {
        throw Exception('Wrong password');
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  @override
  Future<void> register(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print("Error code: ${e.code}");
      if (e.code == AppConstants.weakPassword) {
        throw Exception('The password provided is too weak.');
      } else if (e.code == AppConstants.emailAlreadyInUse) {
        throw Exception('The account already exists for that email.');
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> changeDisplayName(String displayName) async {
    try {
      await _firebaseAuth.currentUser!.updateDisplayName(displayName);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> changePassword(String password) async {
    try {
      await _firebaseAuth.currentUser!.updatePassword(password);
    } catch (e) {
      throw Exception(e);
    }
  }
}
