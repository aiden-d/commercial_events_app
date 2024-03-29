import 'package:amcham_app_v2/screens/events_screen.dart';
import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
        routes: {'/events': (context) => EventsScreen(isPastEvents: false)},
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'PublicSans'),
        home: LandingPage());
  }
}
