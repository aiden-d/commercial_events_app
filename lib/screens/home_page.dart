import 'package:amcham_app_v2/components/forgot_password.dart';
import 'package:amcham_app_v2/constants.dart';
import 'package:flutter/material.dart';
import 'package:amcham_app_v2/components/rounded_button.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'package:amcham_app_v2/components/amcham_logo.dart';
import 'package:amcham_app_v2/size_config.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          body: Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: SizeConfig().getBlockSizeVertical() * 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                    ),
                    Hero(tag: 'logo', child: AmchamLogo()),
                  ],
                ),
                SizedBox(
                  height: SizeConfig().getBlockSizeVertical() * 4,
                ),
                RoundedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  title: 'Login',
                  colour: Colors.white,
                  textStyle: Constants.blueText,
                  radius: 15,
                  height: 80,
                  width: 430,
                ),
                SizedBox(
                  height: 20,
                ),
                RoundedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterScreen()));
                  },
                  title: 'Register',
                  colour: Colors.white,
                  textStyle: Constants.blueText,
                  radius: 15,
                  height: 80,
                  width: 430,
                ),
                SizedBox(
                  height: 30,
                ),
                ForgotPassword(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
