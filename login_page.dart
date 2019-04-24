import 'package:flutter/material.dart';
import 'package:hermitage/auth.dart';
import 'package:hermitage/auth_provider.dart';
import 'package:hermitage/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class FirstNameFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'First Name can\'t be empty' : null;
  }
}

class LastNameFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Last Name can\'t be empty' : null;
  }
}

class EmailFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Email can\'t be empty' : null;
  }
}

class PasswordFieldValidator {
  static String validate(String value) {
    print(value.length);
    if (value.isEmpty) {
      return 'Password can\'t be empty';
    } else if (value.length <= 5) {
      return 'Password must have 6 characters';
    } else {
      return null;
    }
  }
}

class AddressFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Address can\'t be empty' : null;
  }
}

class PhoneFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Phone can\'t be empty' : null;
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({this.onSignedIn});
  final VoidCallback onSignedIn; // call back to the _signIn() function

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

enum FormType { login, register, forgetPassword } // defines the state

class _LoginPageState extends State<LoginPage> {
  
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  String _firstName;
  String _lastName;
  String _address;
  String _phone;
  // initial type is a login
  FormType _formType = FormType.login;
  
  bool isLoading = false;

  bool validateAndSave() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget title() {
    if (_formType == FormType.login) {
      return Text("Login");
    } else if (_formType == FormType.register) {
      return Text("Create Account");
    } else {
      return Text("Forget Password");
    }
  }

  Future<void> validateAndSubmit() async {
    if (validateAndSave()) { // internal validation
      try {
        this.setState(() {
          isLoading = true;// this will set of the circularindicator
        });
        // get the auth from inherited widget
        final BaseAuth auth = AuthProvider.of(context).auth;

        if (_formType == FormType.login) {
          //use signInWithEmailAndPassword from firebase auth
          final String userId =
              await auth.signInWithEmailAndPassword(_email, _password);
          print('Signed in: $userId');
        } else {
          final String userId =
              await auth.createUserWithEmailAndPassword(_email, _password);
          print('Registered user: $userId');

          StreamSubscription<DocumentSnapshot> subscription;
          DocumentReference documentReference;

          documentReference = Firestore.instance.document("users/$userId");
          subscription = documentReference.snapshots().listen((datasnapshot) {
            if (datasnapshot.exists) {
              setState(() {});
            }
          });
          Map<String, String> data = <String, String>{
            "FirstName": _firstName,
            "LastName": _lastName,
            "Email": _email,
            "Address": _address,
            "Phone": _phone,
          };
          documentReference
              .setData(data)
              .whenComplete(() {})
              .catchError((e) => print(e));
        }
        this.setState(() {
          isLoading = false;
        });

        widget.onSignedIn();

        } catch (e) {
        this.setState(() {
          isLoading = false;
        });
        print('Error: $e');
      }
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  void moveToForgetPassword() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.forgetPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: title(),
        elevation: 2.0,
      ),
      backgroundColor: primaryLight,
      body: Stack(
        children: <Widget>[
          Form(
            key: formKey,
            child: ListView(
              children: loginSignUpPages(),
            ),
          ),
          Positioned(
            child: Center(
              child: isLoading
                  ? Container(
                      height: 180.0,
                      width: 280.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: primaryDark.withOpacity(0.9),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(primaryLight)),
                      ),
                    )
                  : Container(),// else give an empty container
            ),
          )
        ],
      ),
    );
  }
// this is a list of widgets for a ListView
  List<Widget> loginSignUpPages() {
    // initial this will be true
    if (_formType == FormType.login) { // this is the first instance when this clas is running
      return <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Container(
            height: 230.0,
            child: Image.asset(
              'assets/images/logo.png',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          child: TextFormField(
            key: Key('email'),
            decoration: InputDecoration(labelText: 'Email'),
            validator: EmailFieldValidator.validate,
            onSaved: (String value) => _email = value,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          child: TextFormField(
            key: Key('password'),
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: PasswordFieldValidator.validate,
            onSaved: (String value) => _password = value,
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          child: RaisedButton(
              key: Key('signIn'),
              color: primaryMedium,
              child: Text('Login', style: TextStyle(fontSize: 20.0)),
              onPressed: validateAndSubmit, //has a local validation check as well as firebase signinemailandpassword
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
        ),
        SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RaisedButton(
                  color: primaryMedium,
                  child:
                      Text('Create Account', style: TextStyle(fontSize: 15.0)),
                  onPressed: moveToRegister,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
              RaisedButton(
                  color: primaryMedium,
                  child: Text('Forget Password ?',
                      style: TextStyle(fontSize: 15.0)),
                  onPressed: moveToForgetPassword,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
            ],
          ),
        ),
      ];
    } else if (_formType == FormType.forgetPassword) {
      return <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Container(
            height: 230.0,
            child: Image.asset(
              'assets/images/logo.png',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          child: Text("Please email HIA team, we will reset your password!",
              style: TextStyle(fontSize: 20.0)),
        ),
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          child: Text("Email: HIAHermitage@gmail.com",
              style: TextStyle(fontSize: 18.0)),
        ),
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RaisedButton(
                  color: primaryMedium,
                  padding: EdgeInsets.only(left: 40.0, right: 40.0),
                  child: Text('Login', style: TextStyle(fontSize: 15.0)),
                  onPressed: moveToLogin,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
              RaisedButton(
                  color: primaryMedium,
                  child:
                      Text('Create Account', style: TextStyle(fontSize: 15.0)),
                  onPressed: moveToRegister,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
            ],
          ),
        )
      ];
    } else {
      return <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          child: TextFormField(
            key: Key('firstName'),
            decoration: InputDecoration(labelText: 'First Name'),
            validator: FirstNameFieldValidator.validate,
            onSaved: (String value) => _firstName = value,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          child: TextFormField(
            key: Key('lastName'),
            decoration: InputDecoration(labelText: 'Last Name'),
            validator: LastNameFieldValidator.validate,
            onSaved: (String value) => _lastName = value,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          child: TextFormField(
            key: Key('email'),
            decoration: InputDecoration(labelText: 'Email'),
            validator: EmailFieldValidator.validate,
            onSaved: (String value) => _email = value,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          child: TextFormField(
            key: Key('password'),
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: PasswordFieldValidator.validate,
            onSaved: (String value) => _password = value,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          child: TextFormField(
            key: Key('address'),
            decoration: InputDecoration(labelText: 'Address'),
            validator: AddressFieldValidator.validate,
            onSaved: (String value) => _address = value,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          child: TextFormField(
            key: Key('phone'),
            decoration: InputDecoration(labelText: 'Phone'),
            validator: PhoneFieldValidator.validate,
            onSaved: (String value) => _phone = value,
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          child: RaisedButton(
              color: primaryMedium,
              child: Text('Create Account', style: TextStyle(fontSize: 20.0)),
              onPressed: validateAndSubmit,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              RaisedButton(
                  color: primaryMedium,
                  padding: EdgeInsets.only(left: 40.0, right: 40.0),
                  child: Text('Login', style: TextStyle(fontSize: 20.0)),
                  onPressed: moveToLogin,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
            ],
          ),
        ),
      ];
    }
  }
}
