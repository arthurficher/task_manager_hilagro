import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final DateTime? lastSignIn;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.lastSignIn,
  });

  factory User.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      lastSignIn: firebaseUser.metadata.lastSignInTime,
    );
  }

  @override
  List<Object?> get props => [id, email, name, photoUrl, lastSignIn];
}