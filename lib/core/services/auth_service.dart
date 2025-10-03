import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hims/core/models/hims_user.dart';

class AuthService {
  static final AuthService _authService = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HimsUser? _currentUser;
  bool _isAuthorized = false;
  String _contactText = '';
  String _errorMessage = '';

  AuthService._internal();
  factory AuthService() => _authService;

  // Getters
  HimsUser? get currentUser => _currentUser;
  bool get isAuthorized => _isAuthorized;
  String get contactText => _contactText;
  String get errorMessage => _errorMessage;

  void _setUser(HimsUser? user) {
    _currentUser = user;
    _isAuthorized = user != null;
    _contactText = user?.name ?? user?.email ?? '';
  }

  Future<void> _ensureInitialized() {
    return GoogleSignInPlatform.instance.init(const InitParameters())
      ..catchError((dynamic _) {});
  }

  /// Проверка сохранённой авторизации
  Future<bool> checkAuthenticationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn && _auth.currentUser != null) {
        final firebaseUser = _auth.currentUser!;

        // Получаем данные из Firestore
        final doc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (doc.exists) {
          print(doc.data()!);
          final himsUser = HimsUser.fromFirestore(doc.data()!, doc.id);
          _setUser(himsUser.updateLastLogin());
          return true;
        } else {
          // Если пользователя нет в Firestore, создаем его
          final himsUser = HimsUser.fromFirebaseUser(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? firebaseUser.email ?? '',
            photoUrl: firebaseUser.photoURL,
            authProvider: 'unknown',
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );

          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .set(himsUser.toFirestore());
          _setUser(himsUser);
          return true;
        }
      }
      return false;
    } catch (e) {
      _errorMessage = 'Ошибка проверки статуса авторизации: $e';
      return false;
    }
  }

  /// Авторизация через Google
  Future<bool> signInWithGoogle() async {
    try {
      _errorMessage = '';
      await _ensureInitialized();

      final AuthenticationResults result = await GoogleSignInPlatform.instance
          .authenticate(const AuthenticateParameters());

      final googleAuth = result.authenticationTokens;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, // а сюда idToken
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) return false;

      // Создаем или обновляем HimsUser
      final himsUser = HimsUser.fromFirebaseUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
        authProvider: 'google',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      _setUser(himsUser);

      // Сохраняем вход
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      print(
        "Firestore write => id: ${himsUser.id}, auth uid: ${firebaseUser.uid}",
      );
      print("toFirestore => ${himsUser.toFirestore()}");

      // Сохраняем в Firestore
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(himsUser.toFirestore(), SetOptions(merge: false));

      return true;
    } catch (e) {
      _errorMessage = 'Ошибка Google авторизации: $e';
      signOut(); // Очистка состояния при ошибке
      return false;
    }
  }

  /// Регистрация через email/пароль
  Future<bool> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      _errorMessage = '';

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) return false;

      // Создаем HimsUser
      final himsUser = HimsUser.fromFirebaseUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? email,
        name: name,
        photoUrl: null,
        authProvider: 'email',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      print(himsUser.toFirestore());

      // Сохраняем в Firestore
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(himsUser.toFirestore());

      _setUser(himsUser);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = "Ошибка регистрации: ${e.message}";
      return false;
    } catch (e) {
      _errorMessage = "Неожиданная ошибка регистрации: $e";
      return false;
    }
  }

  /// Логин через email/пароль
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _errorMessage = '';

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) return false;

      // Получаем данные из Firestore
      try {
        final doc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (doc.exists) {
          // Создаем HimsUser из Firestore данных
          final himsUser = HimsUser.fromFirestore(doc.data()!, doc.id);
          _setUser(himsUser.updateLastLogin());
        }
      } catch (e) {
        print('Ошибка получения данных из Firestore: $e');
        // Fallback - создаем базового пользователя
        final himsUser = HimsUser.fromFirebaseUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? email,
          name: firebaseUser.displayName ?? email,
          authProvider: 'email',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        _setUser(himsUser);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = "Ошибка входа: ${e.message}";
      return false;
    } catch (e) {
      _errorMessage = "Неожиданная ошибка входа: $e";
      return false;
    }
  }

  /// Выход из аккаунта
  Future<bool> signOut() async {
    try {
      _errorMessage = '';
      await _auth.signOut();
      await GoogleSignInPlatform.instance.signOut(const SignOutParams());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('selectedHomeId');
      await prefs.remove('selectedHomeName');

      _setUser(null);
      return true;
    } catch (e) {
      _errorMessage = 'Ошибка выхода: $e';
      return false;
    }
  }

  /// Очищает сообщение об ошибке
  void clearError() {
    _errorMessage = '';
  }
}
