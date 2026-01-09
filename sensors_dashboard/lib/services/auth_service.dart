// Wszystkie importy muszą być na górze:
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Prosty model użytkownika (zastępuje Firebase User)
class AppUser {
  final String uid;
  final String? displayName;
  final bool isAnonymous;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    this.displayName,
    this.isAnonymous = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'displayName': displayName,
    'isAnonymous': isAnonymous,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    uid: json['uid'],
    displayName: json['displayName'],
    isAnonymous: json['isAnonymous'] ?? true,
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AppUser? _currentUser;
  final _authStateController = StreamController<AppUser?>.broadcast();

  AppUser? get currentUser => _currentUser;
  Stream<AppUser?> get authStateChanges => _authStateController.stream;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');

      if (userJson != null) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = AppUser.fromJson(userData);
        _authStateController.add(_currentUser);
        debugPrint('✅ Restored user session: ${_currentUser?.uid}');
      } else {
        debugPrint('ℹ️ No existing user session');
      }
    } catch (e) {
      debugPrint('❌ Error initializing auth: $e');
    }
  }

  Future<AppUser?> signInAnonymously() async {
    try {
      final uid = _generateUid();

      _currentUser = AppUser(
        uid: uid,
        displayName: 'Guest',
        isAnonymous: true,
      );

      await _saveUser(_currentUser!);
      _authStateController.add(_currentUser);
      debugPrint('✅ Signed in anonymously as: $uid');
      return _currentUser;
    } catch (e) {
      debugPrint('❌ Anonymous authentication error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      _currentUser = null;
      _authStateController.add(null);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');

      debugPrint('✅ User signed out');
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
    }
  }

  Future<void> _saveUser(AppUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('❌ Error saving user: $e');
    }
  }

  String _generateUid() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(999999);
    return 'user_${timestamp}_$randomNum';
  }

  void dispose() {
    _authStateController.close();
  }
}
