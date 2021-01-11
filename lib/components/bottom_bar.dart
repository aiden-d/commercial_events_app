import 'package:amcham_app_v2/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amcham_app_v2/screens/updates_screen.dart';
import 'package:amcham_app_v2/screens/events_screen.dart';
import 'package:amcham_app_v2/screens/profile_screen.dart';

class BottomBar extends StatefulWidget {
  final bool isEventsScreen;
  BottomBar({this.isEventsScreen});
  bool getIsEventsScreen() {
    return isEventsScreen;
  }

  @override
  _BottomBarState createState() =>
      _BottomBarState(isEventsScreen: isEventsScreen);
}

class _BottomBarState extends State<BottomBar> {
  final bool isEventsScreen;
  _BottomBarState({this.isEventsScreen});
  static bool isButton1Active;
  static bool isButton2Active = true;
  static bool isButton3Active;
  void SetDefault() {
    setState(() {
      isButton1Active = false;
      isButton2Active = true;
      isButton3Active = false;
    });
  }

  @override
  void initState() {
    if (isEventsScreen == true) {
      isButton1Active = false;
      isButton2Active = true;
      isButton3Active = false;
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Hero(
        tag: 'navbar',
        child: Material(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(CupertinoIcons.bell),
                color: isButton1Active == true
                    ? Constants.blueThemeColor
                    : Colors.black,
                onPressed: () {
                  setState(() {
                    isButton1Active = true;
                    isButton2Active = false;
                    isButton3Active = false;
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdatesScreen()));
                  });
                },
              ),
              IconButton(
                icon: Icon(CupertinoIcons.calendar),
                color: isButton2Active == true
                    ? Constants.blueThemeColor
                    : Colors.black,
                onPressed: () {
                  setState(() {
                    isButton1Active = false;
                    isButton2Active = true;
                    isButton3Active = false;
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EventsScreen()));
                  });
                },
              ),
              IconButton(
                icon: Icon(CupertinoIcons.person),
                color: isButton3Active == true
                    ? Constants.blueThemeColor
                    : Colors.black,
                onPressed: () {
                  setState(() {
                    isButton1Active = false;
                    isButton2Active = false;
                    isButton3Active = true;
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
