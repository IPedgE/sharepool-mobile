import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_pool/common/Constants.dart';
import 'package:share_pool/model/dto/user/UserDto.dart';
import 'package:share_pool/model/dto/user/UserLoginDto.dart';
import 'package:share_pool/model/dto/user/UserTokenDto.dart';
import 'package:share_pool/util/rest/UserRestClient.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  final Widget followingPage;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  UserDto userDto;

  LoginForm(this.followingPage, this._scaffoldKey, this.userDto);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  String _userNameOrEmail = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email or Username",
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return "Email or Username must not be empty";
                }
              },
              onSaved: (String value) {
                _userNameOrEmail = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
              validator: (value) {
                if (value.isEmpty) {
                  return "Password must not be empty";
                }
              },
              onSaved: (String value) {
                _password = value;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: <Widget>[
                  Spacer(),
                  RaisedButton(
                      onPressed: () {
                        var form = _formKey.currentState;
                        if (form.validate()) {
                          form.save();
                          doLogin();
                        }
                      },
                      child: Text('Submit')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void doLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      UserCredentialsDto credentials = await UserRestClient.loginUser(
          new UserLoginDto(_userNameOrEmail, _password));

      if (credentials != null) {
        prefs.setString(Constants.SETTINGS_USER_TOKEN, credentials.userToken);
        prefs.setInt(Constants.SETTINGS_USER_ID, credentials.userId);

        widget.userDto = await UserRestClient.getUser();

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => widget.followingPage));
      } else {
        widget._scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Invalid Credentials'),
          duration: Duration(seconds: 3),
        ));
      }
    } on SocketException catch (e) {
      widget._scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Something went wrong!'),
        duration: Duration(seconds: 3),
      ));
    }
  }
}