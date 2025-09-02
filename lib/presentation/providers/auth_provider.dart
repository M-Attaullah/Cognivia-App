import 'package:flutter/foundation.dart';
import 'package:cognivia_app/data/models/user_model.dart';
import 'package:cognivia_app/data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService() {
    // Initialize auth state listener
    _initAuthStateListener();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Initialize auth state listener
  void _initAuthStateListener() {
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        // User is signed in, we would fetch user data from database here
        // For now, we'll create a basic UserModel
        _currentUser = UserModel(
          id: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          joinedAt: DateTime.now(),
        );
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _setLoading(false);
        return true;
      } else {
        _setError('Sign in failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign up with email, password and name
  Future<bool> signUp(String email, String password, String name) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );

      if (user != null) {
        _currentUser = user;
        _setLoading(false);
        return true;
      } else {
        _setError('Sign up failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _currentUser = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
