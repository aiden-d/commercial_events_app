import 'package:amcham_app_v2/screens/single_news_screen.dart';
import 'package:flutter/material.dart';
import 'package:amcham_app_v2/screens/single_event_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:amcham_app_v2/constants.dart';
import 'get_firebase_image.dart';
import 'package:amcham_app_v2/scripts/member_checker.dart';

class NewsItem extends StatelessWidget {
  //date must be formated as year/month/day/hour/minute
  final int? dateTime;
  //time formatted as hhmm or hour hour minute minute
  final String? summaryText;
  final String? imageRef;
  final String? info;
  final String id;
  final List? tier1hashes;
  final List? tier2hashes;
  final List? tier3hashes;
  final String? title;
  final String? link;
  bool? isButton;

  bool? showInfo;
  bool? hideSummary;
  bool isInfoSelected = true;
  Function? infoButtonFunction;
  Function? speakersButtonFunction;
  bool enableImage = false;

  NewsItem({
    required this.link,
    required this.dateTime,
    required this.summaryText,
    required this.imageRef,
    required this.info,
    required this.id,
    required this.tier1hashes,
    required this.tier2hashes,
    required this.tier3hashes,
    required this.title,
  });
  int? rankedPoints;

  int getPointsFromHashes(List<int> searchHashes) {
    int points = 0;
    for (int searchHash in searchHashes) {
      for (var hash in tier1hashes!) {
        if (hash == searchHash) {
          points += 100;
        }
      }
      for (var hash in tier2hashes!) {
        if (hash == searchHash) {
          points += 75;
        }
      }
      for (var hash in tier3hashes!) {
        if (hash == searchHash) {
          points += 30;
        }
      }
      // for (int hash in tier4hashes) {
      //   if (hash == searchHash) {
      //     points += 15;
      //   }
      // }
      //Commented out to increase performance and battery

    }
    print('points = $points');
    rankedPoints = points;
    return points;
  }

  //date must be formated as year/month/day
  String DateToString(int? numberDate) {
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

  String TimeToString(int numberTime) {
    String numberStr = numberTime.toString();
    if (numberStr.length < 4) {
      numberStr = '0' + numberStr;
    }
    String hour = numberStr.substring(0, 2);
    String minute = numberStr.substring(2, 4);
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: isButton == false
          ? null
          : () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SingleNewsScreen(
                            item: this,
                          )));
            },
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title!,
                    style: Constants.regularHeading,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.calendar, color: Colors.black45),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      '${DateToString(this.dateTime)}',
                      style: TextStyle(fontSize: 16, color: Colors.black45),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),

            //TODO put container here
            enableImage == true
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: LoadFirebaseStorageImage(imageRef: imageRef))
                : SizedBox(),
            hideSummary == true ? SizedBox() : Text(summaryText!),

            showInfo == true
                ? Text(
                    info!,
                    style: Constants.regularHeading
                        .copyWith(fontSize: 16, fontStyle: FontStyle.normal),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
