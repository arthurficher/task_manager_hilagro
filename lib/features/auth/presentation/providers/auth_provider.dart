import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;

  AuthProvider(this._firebaseAuth) {
    _listenToAuthChanges();
  }

  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  String? _errorMessage;

  AuthStatus get status {
    return _status;
  }

  User? get currentUser {
    return _currentUser;
  }

  String? get errorMessage {
    return _errorMessage;
  }

  bool get isAuthenticated => _currentUser != null;

  void _listenToAuthChanges() {
    try {
      _firebaseAuth.authStateChanges().listen(
        (User? user) {
          _currentUser = user;
          if (user != null) {
            _status = AuthStatus.authenticated;
            _clearError();
          } else {
            _status = AuthStatus.unauthenticated;
          }
          notifyListeners();
        },
        onError: (error) {
          _setError('Error de autenticación: ${error.toString()}');
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Error al inicializar autenticación: ${e.toString()}');
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _setLoading();
      _clearError();

      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
      notifyListeners(); // Solo notificar en caso de error
    } catch (e) {
      _setError('Error inesperado: ${e.toString()}');
      notifyListeners(); // Solo notificar en caso de error
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _clearError();
    } catch (e) {
      _setError('Error al cerrar sesión: ${e.toString()}');
    }
    notifyListeners();
  }

  void checkAuthState() {
    try {
      _clearError();
      final User? user = _firebaseAuth.currentUser;
      _currentUser = user;
      if (user != null) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _setError('Error al verificar estado: ${e.toString()}');
    }
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
  }

  void _clearError() {
    if (_errorMessage != null) {
    }
    _errorMessage = null;
  }

  void _handleFirebaseError(FirebaseAuthException e) {
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
        _setError(
          'Error de autenticación: ${e.message ?? 'Error desconocido'}',
        );
    }
  }

  void clearError() {
    _clearError();
    if (_status == AuthStatus.error) {
      checkAuthState();
    }
    notifyListeners();
  }
}
