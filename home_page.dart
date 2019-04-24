import 'package:flutter/material.dart';
import 'package:hermitage/auth.dart';
import 'package:hermitage/auth_provider.dart';
import 'package:hermitage/const.dart';

import 'dart:async';

import 'package:hermitage/shopping_page.dart';
import 'package:hermitage/shopping_cart.dart';
import 'package:hermitage/profile_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onSignedOut;

  HomePage(this.onSignedOut);

  @override
  HomeState createState() => new HomeState();
}

enum ViewType { home, cart, profile }

class HomeState extends State<HomePage> {
  ViewType _viewType = ViewType.home;

  Future<void> _signOut(BuildContext context) async {
    try {
      final BaseAuth auth = AuthProvider.of(context).auth;
      await auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  Widget title() {
    if (_viewType == ViewType.home) {
      return Text("Hermitage");
    } else if (_viewType == ViewType.cart) {
      return Text("Shopping Cart");
    } else {
      return Text("Account");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2.0,
          title: title(),
          actions: <Widget>[
            FlatButton(
                child: Icon(
                  Icons.exit_to_app,
                  color: white,
                ),
                onPressed: () => _signOut(context))
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: primaryLight,
          ),
          child: BottomNavigationBar(
              currentIndex: _viewType.index,
              onTap: (int index) {
                setState(() {
                  _viewType = ViewType.values[index];
                });
              },
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                    title: Text('Home',
                        style: TextStyle(
                          fontFamily: "OpenSans",
                        )),
                    icon: Icon(Icons.home)),
                BottomNavigationBarItem(
                    title: Text('Cart',
                        style: TextStyle(
                          fontFamily: "OpenSans",
                        )),
                    icon: Icon(Icons.shopping_cart)),
                BottomNavigationBarItem(
                    title: Text('My HIA',
                        style: TextStyle(
                          fontFamily: "OpenSans",
                        )),
                    icon: Icon(Icons.account_circle)),
              ]),
        ),
        body: Navigation(
          viewType: _viewType,
        ));
  }
}

class Navigation extends StatelessWidget {
  final ViewType viewType;

  Navigation({this.viewType});

  @override
  Widget build(BuildContext context) {
    if (viewType == ViewType.home) {
      return ShoppingPage();
    } else if (viewType == ViewType.cart) {
      return ShoppingCartPage();
    } else {
      return ProfilePage();
    }
  }
}
