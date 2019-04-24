import 'package:flutter/material.dart';
import 'package:hermitage/auth.dart';

class AuthProvider extends InheritedWidget {
  const AuthProvider({Key key, Widget child, this.auth}) : super(key: key, child: child); // just put this.auth

  final BaseAuth auth; // a variable of class BaseAuth that has access to all the class methods. Check the Auth class which extends baseAuth

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static AuthProvider of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(AuthProvider);
  }
}
