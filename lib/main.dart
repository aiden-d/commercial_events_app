import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'push_nofitications.dart';

void main() {
  PushNotificationsManager notificationsManager =
      new PushNotificationsManager();
  notificationsManager.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
        home: LandingPage());
  }
}
