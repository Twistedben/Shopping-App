import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

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
      notifyListeners(); // Tells consumer in main.dart to rebuild the materialapp
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
}
