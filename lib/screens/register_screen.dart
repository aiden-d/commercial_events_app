import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amcham_app_v2/constants.dart';
import 'package:amcham_app_v2/components/rounded_button.dart';
import 'package:amcham_app_v2/components/rounded_text_field.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:amcham_app_v2/components/amcham_logo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'verify_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _alertDialogBuilder(String error) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Container(
              child: Text(error),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Close Dialog"))
            ],
          );
        });
  }

  CollectionReference users = FirebaseFirestore.instance.collection('UserInfo');
  Future<void> addUserInfo() {
    return users
        .doc(_email)
        .set({
          'first_name': _firstName, // John Doe
          'company': _company, // Stokes and Sons
          'last_name': _lastName,
          'email': _email,

          // 42
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  //create new user account
  Future<String> _createAccount() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return ('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        return ('The account already exists for that email.');
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  //submit form
  void _submitForm() async {
    setState(() {
      isLoading = true;
    });
    String _createAccountFeedback = await _createAccount();
    if (_createAccountFeedback != null) {
      _alertDialogBuilder(_createAccountFeedback);
    } else {
      await addUserInfo();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: ((context) => VerifyScreen())));
      //Navigator.pop(context);
    }
    setState(() {
      isLoading = false;
    });
  }

  bool isLoading = false;
  String _firstName = "";
  String _lastName = "";
  String _email = "";
  String _password = "";
  String _passwordConf = "";
  String _company = "";
  FocusNode _lastNameFocusNode;
  FocusNode _companyFocusNode;
  FocusNode _emailFocusNode;
  FocusNode _passwordFocusNode;
  FocusNode _passwordConfFocusNode;
  @override
  void initState() {
    _lastNameFocusNode = FocusNode();
    _companyFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _passwordConfFocusNode = FocusNode();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _lastNameFocusNode.dispose();
    _companyFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfFocusNode.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  bool validateFields() {
    if (_firstName == "") {
      _alertDialogBuilder('First Name cannot be empty');
      return false;
    }
    if (_lastName == "") {
      _alertDialogBuilder('Last name cannot be empty');
      return false;
    }
    if (_company == "") {
      _alertDialogBuilder('Company cannot be empty');
      return false;
    }
    if (_email == "") {
      _alertDialogBuilder('Email cannot be empty');
      return false;
    }
    if (_password == "") {
      _alertDialogBuilder('Password cannot be empty');
      return false;
    }
    if (_passwordConf == "") {
      _alertDialogBuilder('Password confirmation cannot be empty');
      return false;
    }
    if (_passwordConf != _password) {
      _alertDialogBuilder('Passwords do not match');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("lib/images/TreeBackground.png"),
              fit: BoxFit.cover)),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  Stack(
                    children: [
                      IconButton(
                        padding: EdgeInsets.all(5),
                        iconSize: 50,
                        alignment: Alignment.topLeft,
                        onPressed: () {
                          print("pressed");
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          CupertinoIcons.arrow_left,
                          color: Colors.white,
                        ),
                      ),
                      Center(child: Hero(tag: 'logo', child: AmchamLogo())),
                      SizedBox(
                        width: 60,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  RoundedTextField(
                    width: 420,
                    height: 60,
                    radius: 9,
                    hintText: 'First Name',
                    onChanged: (value) {
                      _firstName = value;
                    },
                    onSubmitted: (value) {
                      _lastNameFocusNode.requestFocus();
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  RoundedTextField(
                    width: 420,
                    height: 60,
                    radius: 9,
                    hintText: 'Last Name',
                    onChanged: (value) {
                      _lastName = value;
                    },
                    focusNode: _lastNameFocusNode,
                    onSubmitted: (value) {
                      _companyFocusNode.requestFocus();
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  RoundedTextField(
                    width: 420,
                    height: 60,
                    radius: 9,
                    hintText: 'Company',
                    onChanged: (value) {
                      _company = value;
                    },
                    focusNode: _companyFocusNode,
                    onSubmitted: (value) {
                      _emailFocusNode.requestFocus();
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  RoundedTextField(
                    width: 420,
                    height: 60,
                    radius: 9,
                    hintText: 'Email',
                    onChanged: (value) {
                      _email = value.toLowerCase();
                    },
                    focusNode: _emailFocusNode,
                    onSubmitted: (value) {
                      _passwordFocusNode.requestFocus();
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  RoundedTextField(
                    width: 420,
                    height: 60,
                    radius: 9,
                    hintText: 'Password',
                    onChanged: (value) {
                      _password = value;
                    },
                    focusNode: _passwordFocusNode,
                    onSubmitted: (value) {
                      _passwordConfFocusNode.requestFocus();
                    },
                    isPasswordField: true,
                    textInputAction: TextInputAction.next,
                  ),
                  RoundedTextField(
                    width: 420,
                    height: 60,
                    radius: 9,
                    hintText: 'Confirm Password',
                    focusNode: _passwordConfFocusNode,
                    isPasswordField: true,
                    onChanged: (value) {
                      _passwordConf = value;
                    },
                    onSubmitted: (value) {
                      if (validateFields() == true) {
                        _submitForm();
                      }
                    },

                    //TODO: impliment password checking functionality
                  ),
                  RoundedButton(
                    onPressed: () {
                      //_alertDialogBuilder();
                      if (validateFields() == true) {
                        _submitForm();
                      }
                    },
                    isLoading: isLoading,
                    title: 'Register',
                    textStyle: Constants.blueText,
                    width: 400,
                    height: 60,
                    radius: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
