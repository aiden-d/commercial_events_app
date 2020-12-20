import 'package:amcham_app_v2/constants.dart';
import 'package:amcham_app_v2/screens/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:amcham_app_v2/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:amcham_app_v2/components/bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:amcham_app_v2/components/rounded_text_field.dart';
import 'package:amcham_app_v2/size_config.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String email;
  String firstName;
  String lastName;
  String company;
  bool isInfoLoading;
  bool isPasswordLoading;
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
  void initState() {
    User user = FirebaseAuth.instance.currentUser;
    email = user.email;
    getInfo();

    super.initState();
  }

  CollectionReference users = FirebaseFirestore.instance.collection('UserInfo');
  Future<void> updateUserInfo() {
    return users
        .doc(email)
        .set({
          'first_name': firstName, // John Doe
          'company': company, // Stokes and Sons
          'last_name': lastName,

          // 42
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  void getInfo() async {
    await FirebaseFirestore.instance
        .collection('UserInfo')
        .doc(email)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data();
        setState(() {
          firstName = data["first_name"];
          print(firstName);
          lastName = data["last_name"];
          print(lastName);
          company = data["company"];
          print(company);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBar(),
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      Center(
                        child: Text(
                          'YOUR INFO',
                          style: TextStyle(
                              fontSize: 50, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Email: ',
                              style: Constants.regularHeading,
                            ),
                            Text(
                              '   $email',
                              style: Constants.regularHeading,
                            )
                          ],
                        ),
                      ),
                      dataInput(
                        title: 'First Name',
                        data: firstName,
                        onChanged: (value) {
                          firstName = value;
                        },
                      ),
                      dataInput(
                        title: 'Last Name',
                        data: lastName,
                        onChanged: (value) {
                          lastName = value;
                        },
                      ),
                      dataInput(
                        title: 'Company',
                        data: company,
                        onChanged: (value) {
                          company = value;
                        },
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Center(
                        child: RoundedButton(
                          boxDecoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(30)),
                          width: 350,
                          height: 60,
                          title: "Apply Info",
                          textStyle:
                              TextStyle(color: Colors.black, fontSize: 25),
                          colour: Colors.white,
                          onPressed: () async {
                            setState(() {
                              isInfoLoading = true;
                            });
                            await updateUserInfo();
                            setState(() {
                              isInfoLoading = false;
                            });
                          },
                          isLoading: isInfoLoading,
                        ),
                      ),
                      Center(
                        child: RoundedButton(
                          boxDecoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(30)),
                          width: 350,
                          height: 60,
                          title: "Reset Password",
                          textStyle:
                              TextStyle(color: Colors.black, fontSize: 25),
                          colour: Colors.white,
                          onPressed: () async {
                            setState(() {
                              isPasswordLoading = true;
                            });
                            await _firebaseAuth.sendPasswordResetEmail(
                                email: email);
                            setState(() {
                              isPasswordLoading = false;
                            });
                            return _alertDialogBuilder('Sent',
                                'Check your email to reset your password');
                          },
                          isLoading: isPasswordLoading,
                        ),
                      ),
                      Center(
                        child: RoundedButton(
                          width: 350,
                          height: 60,
                          title: "Log Out",
                          textStyle:
                              TextStyle(color: Colors.white, fontSize: 25),
                          colour: Constants.blueThemeColor,
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LandingPage()));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class dataInput extends StatelessWidget {
  const dataInput(
      {Key key,
      @required this.title,
      @required this.data,
      @required this.onChanged})
      : super(key: key);

  final String title;
  final String data;
  final Function(String) onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$title: ',
            style: Constants.regularHeading,
          ),
          RoundedTextField(
            border: Border.all(color: Colors.black),
            hintText: '$title...',
            textValue: data,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
