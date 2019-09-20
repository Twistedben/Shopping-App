import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/http_exception.dart';

import '../providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(
                            -10.0), // Adds offsetting to the matrix, returns void so we use .. (cascade) so that void isn't returned from translate, instead returns the previous chained method from .rotationZ
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color: Theme.of(context).accentTextTheme.title.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(), // Widget below
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  // These two should be configured in initstate
  AnimationController _controller;
  // Animation<Size> // Used for AnimatedBUilder
  //     _heightAnimation; // Since Animation is dynamic, we have to provide what we intend to animate and in this case it's the height so we put size
  AnimationController _controller;
  Animation<Offset> // Used for SlideTransition
      _slideAnimation;
  Animation<double>
      _opacityAnimation; // Allows animation for FadeTransition for password textfield
  // Configures animation by assigning values to the two variables above
  @override
  void initState() {
    super.initState();
    // For AnimationController to work, we have to add a mixin to the class above, using with SingleTickerProviderStateMixin
    // It adds some methods to the State class and let's the widget know when a frame update is due for animations to play smoothly
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    // FOR ANIMATEDBUILDER Tween stores the beginning and end of two values, the information behind the animation. Then we call .animate on it
    // _heightAnimation = Tween<Size>(
    //         begin: Size(double.infinity, 260), end: Size(double.infinity, 320))
    //     .animate(
    //         CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    _slideAnimation = Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    // We need to set a listener to call set state. Here we just want to rerun the build method so animation is played. We should also dispose of this listener by using dispose below.
    // _heightAnimation.addListener(() => setState(() {}));
    // Below - Opacity value setup for FadeTransiontion widget for password textfield.
    _opacityAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  // // Cleans the listener from contreoller
  // @override
  // void dispose() {
  //   super.dispose();
  //   _controller.dispose();
  // }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData["password"],
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['email'],
          _authData['password'],
        );
      }
      // The on catches a specific error. Since we handle our own httpexception class, we deinfed this in auth when the response has an error in it
      // The two catch blocks will allow you to filter the first based on authentication error we defined and the second is a more general error
    } on HttpException catch (error) {
      var errorMessage = "Authentication failed";
      // The error is the HttpException that has the message we assigned it in auth,being the response's error
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = "This email address already has an account";
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = "This email address is not valid";
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = "This password is too weak";
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = "Could not find an account with this email.";
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = "Wrong password.";
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          "Could not authenticate you. Please try again later.";
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      // Fire the animation. .forward() starts the animation
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      // Reverse the animation back.
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      // Below we use the AnimatedBUIlder widget, builder to tell it what to rebuild during animation, childWidget is not rebuilt
      child:
          //   Approach 1: Animated Builder
          //   Uses and controller and values set above in init state
          //   AnimatedBuilder(
          //   animation: _heightAnimation,
          //   builder: (ctx, childWidget) =>
          // Approach 2: Animated Container
          // AnimatedContainer just needs a duration and curve, and manual input for height and changes using ternary is how it determines the animation, without the need for a controller and manual definition
          AnimatedContainer(
        duration: Duration(milliseconds: 300), // Needed for AnimatedContainer
        curve: Curves.easeIn, // Needed for AnimatedContainer
        height: _authMode == AuthMode.Signup ? 320 : 260,
        // height: _heightAnimation.value.height, // Needed for AnimatedBuilder
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        //     BoxConstraints(minHeight: _heightAnimation.value.height), // Needed for AnimatedBuilder
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        // Approach 1:
        // child:
        //     childWidget), // Child of the AnimatedBUilder that WONT rebuild each animation, unlike the Container() above
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                // if (_authMode == AuthMode.Signup) // Without Animation
                // Fade Transition takes anopacity that needs a controler, instantiated above. Still needs the controller to be started and reversed, which is done in the _switchAuthMode method
                // AnimatedContainer is used to remove the reserved space on the login form for the FadeTransition, so we use the logic of whether the space should be there if on signup or login.
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.Signup ? 120 : 0),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
