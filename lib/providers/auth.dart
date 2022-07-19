import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiry;
  Timer? _authTimer;
  String? _userId;
  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiry != null && _expiry!.isAfter(DateTime.now()) && _token != null) {
      return _token;
    }
    return null;
  }

  String? get userID {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBwiwGJ8vIvA3uG1r81FRSYlE2UVFl-QY0';
    try {
      final res = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final responseData = json.decode(res.body);
      if (responseData['error'] != null) {
        print(responseData['error']['message']);
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiry = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      autoLogout();
      notifyListeners();
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String userData = json.encode({
        'token': _token,
        'userId': _userId,
        'exipryDate': _expiry.toString()
      });

      _pref.setString('userData', userData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<bool> tryAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;
    final Map<String, dynamic>? userData =
        json.decode(prefs.getString('userData')) as Map<String, dynamic>?;
    final  DateTime? expiryDate = DateTime.parse(userData!['exipryDate']);
    if (expiryDate!.isBefore(DateTime.now())) return false;
    _token = userData['token'] as String?;
    _userId = userData['userId'] as String?;
    _expiry = expiryDate;

    notifyListeners();
    autoLogout();
    return true;
  }

  Future<void> logout() async {
    _expiry = null;
    _token = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final shared = await SharedPreferences.getInstance();
    shared.clear();
  }

  void autoLogout() {
    if (_authTimer != null) _authTimer!.cancel();
    final timerToExpiry = _expiry!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timerToExpiry), logout);
  }
}
