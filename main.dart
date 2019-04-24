import 'package:flutter/material.dart';

import 'package:hermitage/auth.dart';
import 'package:hermitage/auth_provider.dart';
import 'package:hermitage/const.dart';
import 'package:hermitage/root_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      auth: Auth(),
      child: MaterialApp(
        title: 'Hermitage',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: primaryDark,
        ),
        home: RootPage(),
      ),
    );
  }
}
