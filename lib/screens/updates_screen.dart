import 'package:amcham_app_v2/constants.dart';
import 'package:flutter/material.dart';
import 'package:amcham_app_v2/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:amcham_app_v2/components/bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:web_browser/web_browser.dart';

class UpdatesScreen extends StatefulWidget {
  @override
  _UpdatesScreenState createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  String messageTitle = "Empty";
  String notificationAlert = "alert";

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
