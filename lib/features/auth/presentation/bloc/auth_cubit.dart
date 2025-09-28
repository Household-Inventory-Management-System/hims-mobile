import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

enum AuthState { loading, authenticated, unauthenticated }

class AuthData {
  final GoogleSignInUserData? currentUser;
  final bool isAuthorized;
  final String contactText;
  final String errorMessage;

  AuthData({
    this.currentUser,
    this.isAuthorized = false,
    this.contactText = '',
    this.errorMessage = '',
  });

  AuthData copyWith({
    GoogleSignInUserData? currentUser,
    bool? isAuthorized,
    String? contactText,
    String? errorMessage,
  }) {
    return AuthData(
      currentUser: currentUser ?? this.currentUser,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      contactText: contactText ?? this.contactText,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState.loading);

  // Google Sign-In state
  GoogleSignInUserData? _currentUser;
  final bool _isAuthorized = false;
  final String _contactText = '';
  String _errorMessage = '';
  Future<void>? _initialization;

  // Getters for UI
  GoogleSignInUserData? get currentUser => _currentUser;
  bool get isAuthorized => _isAuthorized;
  String get contactText => _contactText;
  String get errorMessage => _errorMessage;

  Future<void> _ensureInitialized() {
    return _initialization ??= GoogleSignInPlatform.instance.init(
      const InitParameters(),
    )..catchError((dynamic _) {
      _initialization = null;
    });
  }

  void _setUser(GoogleSignInUserData? user) {
    _currentUser = user;
  }

  Future<void> signInWithGoogle() async {
    emit(AuthState.loading);
    await _ensureInitialized();
    try {
      final AuthenticationResults? result = await GoogleSignInPlatform.instance
          .attemptLightweightAuthentication(
            const AttemptLightweightAuthenticationParameters(),
          );
      _setUser(result?.user);
      if (result?.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        emit(AuthState.authenticated);
      }
    } on GoogleSignInException catch (e) {
      _errorMessage =
          e.code == GoogleSignInExceptionCode.canceled
              ? ''
              : 'GoogleSignInException ${e.code}: ${e.description}';
      emit(AuthState.unauthenticated);
    }
  }

  Future<void> handleSignIn() async {
    emit(AuthState.loading);
    try {
      await _ensureInitialized();
      final AuthenticationResults result = await GoogleSignInPlatform.instance
          .authenticate(const AuthenticateParameters());
      _setUser(result.user);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      emit(AuthState.authenticated);
    } on GoogleSignInException catch (e) {
      _errorMessage =
          e.code == GoogleSignInExceptionCode.canceled
              ? ''
              : 'GoogleSignInException ${e.code}: ${e.description}';
      emit(AuthState.unauthenticated);
    }
  }

  Future<void> handleSignOut() async {
    await _ensureInitialized();
    await GoogleSignInPlatform.instance.disconnect(const DisconnectParams());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    emit(AuthState.unauthenticated);
  }
}
