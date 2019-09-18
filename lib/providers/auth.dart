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
      // Begin - Shared Preferences - Local Data storage
      // Store log in data using shared_prefernces. Imported above. Shared Preferences works with futures and needs async
      final prefs = await SharedPreferences.getInstance();
      // We convert the data into a JSON Map (which is a string so can be set using setString on share_pref) to store using setString for Shared_prefernces
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      // set is used to write data. The key is up to you for naming convention
      prefs.setString('userData', userData);
      // End - Shared Preferences
    } catch (error) {
      throw error;
    }
  }

  // Auto login, used in Main.dart. Returns a boolean since it should reflect true = being successful logging in or false, failing to log in.
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    // If prefs doesn't contain the key 'userData', which we set above in _authenticate, then we know they haven't logged in
    if (!prefs.containsKey('userData')) {
      return false; // Exits future, returning false
    }
    // Now, since the above failed, and there is local storage wich has userData, we can retreive it. We convert it from a string to a map
    final localUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    // Now we check if expiration date is before the current time, meaning it has expired and is invalid to we break out, returning false.
    final expiryDate = DateTime.parse(localUserData[
        'expiryDate']); // We parse that iso string we stored to a real dateTime so we can check it below against DateTime.now
    if (expiryDate.isBefore(DateTime.now())) {
      return false; // Exits future, returning false
    }
    // Now that we've checked these possible invalid authentication states, we want to log the user in using all the data we stored in shared_prefernces above method, tapping into the Map variable we created above.
    _token = localUserData['token'];
    _expiryDate = expiryDate;
    _userId = localUserData['userId'];
    notifyListeners(); // Update UI
    _autoLogout(); // Set autoLogout timer
    return true; // Autologin succeeded, returning true to Future
  }

  // Sign up for user
  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  // Log in for user
  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    // Access the local storage to clear it so that it doesn't auto login successfully
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData'); // Good to use if you're storing multiple key/value data in local storage and want to target a specific set to remove
    prefs.clear(); // Removes all local storage data
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
