import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shops_app/models/http_exception.dart';
import 'package:shops_app/providers/auth.dart';

enum AuthMode { SignUp, Login }

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth-screen';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
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
                  stops: [0, 1]),
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
                      transform: Matrix4.rotationZ((-8 * pi) / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.deepOrange.shade900,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8.0,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            )
                          ]),
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
                    child: AuthCard(),
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
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final passwordController = TextEditingController();

  AuthMode _authmode = AuthMode.Login;
  var _isLoading = false;
  Map<String, String> _authdata = {
    'email': '',
    'password': '',
  };

  AnimationController _controller;
  // Animation<Size> _heightAnimation;
  Animation<double> _opacityAnimationController;
  Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    // _heightAnimation = Tween<Size>(
    //   begin: Size(double.infinity, 260),
    //   end: Size(double.infinity, 320),
    // ).animate(
    //   CurvedAnimation(
    //     parent: _controller,
    //     curve: Curves.linear,
    //   ),
    // );
    // _heightAnimation.addListener(() => setState(() {})); --> without Animation Builder
    _slideAnimation =
        Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimationController = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  void _switchAuthMode() {
    if (_authmode == AuthMode.Login) {
      setState(() {
        _authmode = AuthMode.SignUp;
      });
      _controller.forward();
    } else {
      setState(() {
        _authmode = AuthMode.Login;
      });
      _controller.reverse(); // has to be used while manual control
    }
  }

  void _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authmode == AuthMode.Login) {
        // LogIn User
        await Provider.of<Auth>(context, listen: false).login(
          _authdata['email'],
          _authdata['password'],
        );
      } else {
        // SignUp User
        await Provider.of<Auth>(context, listen: false).signUp(
          _authdata['email'],
          _authdata['password'],
        );
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication Failed';

      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email already exists';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Please enter valid email';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Sorry this email does not exists. Please Sign Up';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'The password entered is not correct';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not authenticate';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occured'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Okay')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),

      // child : AnimatedBuilder(
      //   animation: _heightAnimation,
      //   builder: (ctx, ch) =>
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.linear,
        height: _authmode == AuthMode.SignUp ? 320 : 260,
        // height: _heightAnimation.value.height,
        width: deviceSize.width * 0.80,
        constraints: BoxConstraints(
          minHeight: _authmode == AuthMode.SignUp ? 320 : 260,
        ),
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid Email';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) {
                    _authdata['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  controller: passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length <= 4) {
                      return 'Password too short !';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) {
                    _authdata['password'] = value;
                  },
                ),
                // if (_authmode == AuthMode.SignUp)
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  constraints: BoxConstraints(
                    minHeight: _authmode == AuthMode.SignUp ? 60 : 0,
                    maxHeight: _authmode == AuthMode.SignUp ? 120 : 0,
                  ),
                  child: FadeTransition(
                    opacity: _opacityAnimationController,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                        ),
                        obscureText: true,
                        validator: _authmode == AuthMode.SignUp
                            ? (value) {
                                if (value != passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    onPressed: _submit,
                    child: Text(
                      _authmode == AuthMode.Login ? 'LOGIN' : 'SIGN UP',
                    ),
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                    '${_authmode == AuthMode.Login ? 'SIGN UP' : 'LOGIN'} INSTEAD',
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  textColor: Theme.of(context).primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
