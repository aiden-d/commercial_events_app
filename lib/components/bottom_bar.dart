import 'package:amcham_app_v2/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amcham_app_v2/screens/news_screen.dart';
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
  static bool isButton4Active;
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
                tooltip: "News",
                icon: Icon(CupertinoIcons.news_solid),
                color: isButton1Active == true
                    ? Constants.blueThemeColor
                    : Colors.black,
                onPressed: () {
                  setState(() {
                    isButton1Active = true;
                    isButton2Active = false;
                    isButton3Active = false;
                    isButton4Active = false;
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdatesScreen()));
                  });
                },
              ),
              IconButton(
                tooltip: "Upcoming Events",
                icon: Icon(CupertinoIcons.calendar),
                color: isButton2Active == true
                    ? Constants.blueThemeColor
                    : Colors.black,
                onPressed: () {
                  setState(() {
                    isButton1Active = false;
                    isButton2Active = true;
                    isButton3Active = false;
                    isButton4Active = false;
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EventsScreen()));
                  });
                },
              ),
              IconButton(
                  tooltip: "Past Events",
                  icon: Icon(CupertinoIcons.play_circle),
                  color: isButton3Active == true
                      ? Constants.blueThemeColor
                      : Colors.black,
                  onPressed: () {
                    setState(() {
                      isButton1Active = false;
                      isButton2Active = false;
                      isButton3Active = true;
                      isButton4Active = false;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EventsScreen(
                                    isPastEvents: true,
                                  )));
                    });
                  }),
              IconButton(
                tooltip: "Profile",
                icon: Icon(CupertinoIcons.person),
                color: isButton4Active == true
                    ? Constants.blueThemeColor
                    : Colors.black,
                onPressed: () {
                  setState(() {
                    isButton1Active = false;
                    isButton2Active = false;
                    isButton3Active = false;
                    isButton4Active = true;
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
