import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _role;
  String? _token;

  Map<String, dynamic>? get user => _user;
    Map<String, dynamic>? get role => _role;
  String? get token => _token;

  void setUser(Map<String, dynamic>? userData) {
    _user = userData;
    notifyListeners();
  }

  void setRole(Map<String, dynamic>? roleData) {
    _role = roleData;
    notifyListeners();
  }

  void setToken(String? tokenData) {
    _token = tokenData;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _token = null;
    _role = null;
    notifyListeners();
  }
}
