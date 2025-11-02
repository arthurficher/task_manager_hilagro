import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  
  AuthProvider(this._firebaseAuth) {
    _listenToAuthChanges();
  }

  // States
  AuthStatus _status = AuthStatus.initial;
  firebase_auth.User? _currentUser;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  firebase_auth.User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Listen to Firebase Auth state changes
  void _listenToAuthChanges() {
    _firebaseAuth.authStateChanges().listen((user) {
      _currentUser = user;
      if (user != null) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  // LOGIN Method
  Future<void> login(String email, String password) async {
    try {
      _setLoading();
      _clearError();

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (credential.user != null) {
        _currentUser = credential.user;
        _status = AuthStatus.authenticated;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } catch (e) {
      _setError('Error inesperado: ${e.toString()}');
    }
    notifyListeners();
  }

  // LOGOUT Method
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _clearError();
    } catch (e) {
      _setError('Error al cerrar sesión');
    }
    notifyListeners();
  }

  // Helper Methods
  void _setLoading() {
    _status = AuthStatus.loading;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _handleFirebaseError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        _setError('No existe una cuenta con este email');
        break;
      case 'wrong-password':
        _setError('Contraseña incorrecta');
        break;
      case 'invalid-email':
        _setError('Email inválido');
        break;
      case 'user-disabled':
        _setError('Esta cuenta ha sido deshabilitada');
        break;
      case 'too-many-requests':
        _setError('Demasiados intentos. Intente más tarde');
        break;
      case 'network-request-failed':
        _setError('Error de conexión. Verifique su internet');
        break;
      default:
        _setError('Error de autenticación: ${e.message}');
    }
  }

  // Clear error manually
  void clearError() {
    _clearError();
    notifyListeners();
  }
}

