import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _token;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  void setUser(Map<String, dynamic> userData) {
    _user = userData;
    notifyListeners();
  }

  void setToken(String tokenData) {
    _token = tokenData;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }
}
