import 'package:amcham_app_v2/components/rounded_button.dart';
import 'package:amcham_app_v2/constants.dart';
import 'package:amcham_app_v2/screens/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:amcham_app_v2/components/amcham_logo.dart';
import 'dart:async';

class VerifyScreen extends StatefulWidget {
  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final auth = FirebaseAuth.instance;
  User user;
  static Timer timer;
  bool isResendLoading = false;
  @override
  void initState() {
    sendMail();

    super.initState();
  }

  Future<void> _alertDialogBuilder(String title, String info) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title != null ? title : "Error"),
            content: Container(
              child: Text(info),
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

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void sendMail() async {
    user = auth.currentUser;
    await user.sendEmailVerification();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      checkEmailVerified();
    });
  }

  Future<void> checkEmailVerified() async {
    user = auth.currentUser;
    await user.reload();
    if (user.emailVerified) {
      timer.cancel();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LandingPage()));
    }
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
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white),
                  child: Text(
                    'An email has been sent to ${auth.currentUser.email} please verify before logging in...',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              RoundedButton(
                title: 'Resend Email',
                isLoading: isResendLoading,
                onPressed: () {
                  timer.cancel();
                  sendMail();
                  _alertDialogBuilder('Sent',
                      'Another email has been sent to your email, make sure to check the spam folder and please allow a few minutes for it to appear');
                },
              ),
              RoundedButton(
                title: 'Sign Out',
                onPressed: () async {
                  await auth.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LandingPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
