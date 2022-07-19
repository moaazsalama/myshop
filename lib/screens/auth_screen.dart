import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/http_exception.dart';
import '../providers/auth.dart';

Size? devicesize;

class AuthScreen extends StatelessWidget {
  static String routename = "/auth";
  @override
  Widget build(BuildContext context) {
    devicesize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromRGBO(215, 117, 255, 1).withOpacity(.5),
                Color.fromRGBO(255, 188, 117, 1).withOpacity(.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0, 1],
            )),
          ),
          SingleChildScrollView(
            child: Container(
              width: devicesize!.width,
              height: devicesize!.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.deepOrange),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      margin: EdgeInsets.only(bottom: 20),
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 94),
                      child: Text(
                        "My Shop",
                        style: TextStyle(
                          fontFamily: 'Anton',
                          fontSize: 50,
                          color:
                              Theme.of(context).accentTextTheme.headline6!.color,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: AuthCard(),
                    flex: devicesize!.width > 600 ? 2 : 1,
                  )
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

enum AuthMode { Login, SignUp }

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authMap = {'username': '', 'password': ''};
  var _isLoading = false;
  final _passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<Offset> _slidAnimation;
  late Animation<double> _opacityAnimation;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slidAnimation = Tween<Offset>(begin: Offset(0, -15), end: Offset(0, 0))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login)
        await Provider.of<Auth>(context, listen: false)
            .login(_authMap['username']!, _authMap['password']!);
      else
        await Provider.of<Auth>(context, listen: false)
            .signUp(_authMap['username']!, _authMap['password']!);
    } on HttpException catch (error) {
      var errorMessage = "Authentication Failed";
      if (error.toString().contains("EMAIL_EXISTS")) {
        errorMessage = "This Email Adress is Already Use";
      } else if (error.toString().contains("EMAIL_NOT_FOUND")) {
        errorMessage = "This Email Adress is not valid ";
      } else if (error.toString().contains("INVALID_EMAIL")) {
        errorMessage = "This Email Adress is not valid ";
      } else if (error.toString().contains("WEAK_PASSWORD")) {
        errorMessage = "This Password is Weak";
      } else if (error.toString().contains("INVALID_PASSWORD")) {
        errorMessage = "This Password is not valid";
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      const errorMessage =
          "Could not authenticate you. Please Try Again Later.";
      _showErrorDialog(errorMessage);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("An Error Occurred"),
              content: Text(message),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text("Okay!"))
              ],
            ));
  }

  void _switchMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.SignUp ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.SignUp ? 320 : 260),
        width: devicesize!.width * 0.75,
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: (value) {
                    if (!value!.contains('@') || value.isEmpty)
                      return "unValid Email";
                    return null;
                  },
                  onSaved: (newValue) {
                    _authMap['username'] = newValue!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  autocorrect: false,
                  validator: (value) {
                    if (value!.length <= 7 || value.isEmpty)
                      return "unValid password";
                    return null;
                  },
                  onSaved: (newValue) {
                    _authMap['password'] = newValue!;
                  },
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.SignUp ? 60 : 0,
                      maxHeight: _authMode == AuthMode.SignUp ? 120 : 0),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slidAnimation,
                      child: TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        autocorrect: false,
                        validator: _authMode == AuthMode.SignUp
                            ? (value) {
                                if (value != _passwordController.text ||
                                    value!.isEmpty)
                                  return "Pasword is not match ";
                                return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading) CircularProgressIndicator(),
                RaisedButton(
                  child: Text(_authMode == AuthMode.Login ? "Login" : "SignUp"),
                  onPressed: _submit,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).primaryTextTheme.headline6!.color,
                ),
                FlatButton(
                    onPressed: _switchMode,
                    child: Text(
                        '${_authMode == AuthMode.Login ? "SignUp" : "Login"} INSTED'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
