import 'package:amcham_app_v2/components/event_item.dart';
import 'package:amcham_app_v2/components/news_item.dart';
import 'package:amcham_app_v2/components/rounded_button.dart';
import 'package:amcham_app_v2/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amcham_app_v2/components/get_firebase_image.dart';
import 'events_screen.dart';
import 'event_register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class SingleNewsScreen extends StatefulWidget {
  String testStr = '';
  final NewsItem item;
  String DateToString(int numberDate) {
    String strNumberDate = numberDate.toString();
    String year = strNumberDate.substring(0, 4);
    String month = strNumberDate.substring(4, 6);
    int monthInt = int.parse(month);
    List<String> dates = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    month = dates[monthInt - 1];

    String day = strNumberDate.substring(6, 8);
    return '$day $month $year';
  }

  SingleNewsScreen({@required this.item});
  @override
  _SingleNewsScreenState createState() => _SingleNewsScreenState(item: item);
}

class _SingleNewsScreenState extends State<SingleNewsScreen> {
  BoxDecoration activeDecoration = BoxDecoration(
    border: Border(
      bottom: BorderSide(width: 2, color: Colors.lightBlue.shade900),
    ),
  );
  BoxDecoration inActiveDecoration = BoxDecoration();

  bool isInfoActive = true;
  bool isLinkActive = false;
  final NewsItem item;
  String url;
  @override
  void initState() {
    if (item.link != null && item.link != '' && item.link != ' ') {
      isLinkActive = true;
      url = item.link;
      if (url.substring(0, 8) != 'https://' &&
          url.substring(0, 7) != 'http://') {
        url = 'https://' + url;
      } else {}
      print('ss = ' + url);
    }
    BoxDecoration activeDecoration = BoxDecoration(
      border: Border(
        bottom: BorderSide(width: 2, color: Colors.lightBlue.shade900),
      ),
    );
    BoxDecoration inActiveDecoration = BoxDecoration();
    item.isButton = false;
    item.enableImage = true;
    item.showInfo = true;
    item.isInfoSelected = true;
    item.hideSummary = true;
    item.infoButtonFunction = () {
      setState(() {
        print('test');
        item.isInfoSelected = true;
      });
    };
    item.speakersButtonFunction = () {
      print('test');
      setState(() {
        item.isInfoSelected = false;
      });
    };

    super.initState();
  }

  _launchURL() async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch ${url}';
    }
  }

  String userEmail = FirebaseAuth.instance.currentUser.email;

  _SingleNewsScreenState({@required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.blueThemeColor,
      ),
      body: Stack(
        children: [
          Container(
            child: SingleChildScrollView(
              child: item,
            ),
          ),
          isLinkActive == true
              ? Align(
                  child: RoundedButton(
                    title: 'Open Link',
                    onPressed: _launchURL,
                    radius: 10,
                    width: 350,
                    colour: Constants.blueThemeColor,
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  alignment: Alignment.bottomCenter,
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
