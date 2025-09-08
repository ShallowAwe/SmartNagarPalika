import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final String username;
  final String password;

  AuthState({required this.username, required this.password});
}

/// Holds the current logged-in user credentials
final authProvider = StateProvider<AuthState?>((ref) => null);
