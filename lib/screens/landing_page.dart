import 'package:amcham_app_v2/components/amcham_logo.dart';
import 'package:amcham_app_v2/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'events_screen.dart';
import 'package:amcham_app_v2/size_config.dart';
import 'verify_screen.dart';
import 'package:amcham_app_v2/push_nofitications.dart';
import 'dart:async';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  bool showStartScreen = true;
  Timer _timer;
  int _start = 1;
  void startTimer() {
    const oneSec = const Duration(seconds: 3);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            showStartScreen = false;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text("Error: ${snapshot.error}"),
              ),
            );
          }
          if (showStartScreen) {
            return Scaffold(
              backgroundColor: Constants.blueThemeColor,
              body: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                          'lib/images/amchamwidelogotransparent.png'),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Sponsored By:",
                      style: Constants.whiteTextStyle,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 8),
                      child: Container(
                        color: Colors.white,
                        child: Center(
                          child: Text('Advertise here!'),
                        ),
                        padding: EdgeInsets.all(8),
                        height: 50,
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    Expanded(child: SizedBox()),
                    Align(
                      child: Text(
                        "Created by Aiden Dawes",
                        style: Constants.whiteTextStyle,
                      ),
                      alignment: Alignment.bottomCenter,
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    User _user = snapshot.data;
                    SizeConfig().init(context);
                    if (_user == null) {
                      PushNotificationsManager().init();
                      print('need to log in');
                      //user is not logged in
                      return HomePage();
                    } else {
                      print('logged in');
                      if (FirebaseAuth.instance.currentUser.emailVerified ==
                          false) {
                        PushNotificationsManager().init();
                        return VerifyScreen();
                      } else {
                        PushNotificationsManager().init();
                        return EventsScreen();
                      }
                      //user is logged in

                    }
                  }
                  return Scaffold(
                      body: Center(
                          child: Text(
                    "Connecting to the app...",
                    style: Constants.regularHeading,
                  )));
                });
          }
          return Scaffold(
            body: Center(
              child: Text(
                "Connecting to the app...",
                style: Constants.regularHeading,
              ),
            ),
          );
        });
  }
}
