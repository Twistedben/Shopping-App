import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Allows timers

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  String get token {
    // If we have an expiryDate and a token, and it hasn't expired yet, in the future, then return the _token
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    // Otherwise, break out returning null
    return null;
  }

  // Getter that determines if the person has a token, therefore is logged in. Logic is done above, determining if it's valid or not. Used in Main.dart to determine home screen
  bool get isAuth {
    return token != null;
  }

  // Getter returning userId, allowing authData.userId calls to return the user id set in _authenticate
  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyC64p9stcrAsyFZmAKYYb0Lo8aq37zrVyQ';
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      // Since there is no error, we set the token locally to allow them to get to productsoverviewscreen in main.dart
      _token = responseData['idToken']; // From firebase response
      _userId = responseData['localId']; // From firebase response
      // From firebase response, we have to parse this returned string into an actual date
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners(); // Tells consumer in main.dart to rebuild the materialapp
      // Store log in data using shared_prefernces. Imported above. Shared Preferences works with futures and needs async
      final prefs = await SharedPreferences.getInstance();
      // set is used to write data. To store more complex data like a map, you could do "json.encode({})"
      prefs.setString(key, value);
    } catch (error) {
      throw error;
    }
  }

  // Sign up for user
  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  void logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
  }

  // Logs the user out after a certain amount of time. To use the timer feature we import dart:async above. Function is called when logged in to start the timer.
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
