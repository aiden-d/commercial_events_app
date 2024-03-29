import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'size_config.dart';

class Constants {
  static const num = 800;
  static const regularHeading = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.black);
  static const logoTitleStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white);
  static const whiteTextStyle = TextStyle(fontSize: 14, color: Colors.white);
  static const logoTitleStyleRed = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Color(0xD10F41),
    shadows: <Shadow>[
      Shadow(
        offset: Offset(5.0, 5.0),
        blurRadius: 12.0,
        color: Colors.black38,
      ),
    ],
  );
  static const blueThemeColor = Color.fromARGB(1000, 0, 45, 98);
  static const darkBlueThemeColor = Color.fromARGB(1000, 13, 38, 67);
  static const blueText =
      TextStyle(fontSize: 25, color: Constants.blueThemeColor);
  static const testText = Text(
    'test',
  );
}
