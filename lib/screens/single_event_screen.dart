import 'package:amcham_app_v2/components/alert_dialog_builder.dart';
import 'package:amcham_app_v2/components/dialogs.dart';
import 'package:amcham_app_v2/components/event_item.dart';
import 'package:amcham_app_v2/components/event_register_components.dart';
import 'package:amcham_app_v2/components/rounded_button.dart';
import 'package:amcham_app_v2/constants.dart';
import 'package:amcham_app_v2/screens/events_screen.dart';
import 'package:amcham_app_v2/scripts/member_checker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'event_register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SingleEventScreen extends StatefulWidget {
  final EventItem item;
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

  SingleEventScreen({required this.item});
  @override
  _SingleEventScreenState createState() => _SingleEventScreenState(item: item);
}

class _SingleEventScreenState extends State<SingleEventScreen> {
  BoxDecoration activeDecoration = BoxDecoration(
    border: Border(
      bottom: BorderSide(width: 2, color: Colors.lightBlue.shade900),
    ),
  );
  BoxDecoration inActiveDecoration = BoxDecoration();
  bool refreshEvents = false;
  bool isInfoActive = true;
  bool? addtoCalendarBool = true;

  EventItem item;
  @override
  void initState() {
    setState(() {
      item.showVid = true;
    });

    BoxDecoration activeDecoration = BoxDecoration(
      border: Border(
        bottom: BorderSide(width: 2, color: Colors.lightBlue.shade900),
      ),
    );
    BoxDecoration inActiveDecoration = BoxDecoration();
    item.isButton = false;
    item.showInfo = true;
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
    print('speakers = ${item.speakers}');
    speakersList = new SpeakersList(
      speakers: item.speakers as List<dynamic>,
    );
    speakersList.generateSpeakers();

    super.initState();
  }

  Future<void> _alertDialogBuilder(
      String title, String info, Function? closeFunction) async {
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
                  onPressed: closeFunction != null
                      ? closeFunction as void Function()?
                      : () {
                          Navigator.pop(context);
                        },
                  child: Text("Close Dialog"))
            ],
          );
        });
  }

  String? userEmail = FirebaseAuth.instance.currentUser!.email;
  bool checkOwnedEvent() {
    if (item.registeredUsers == null) {
      return false;
    }
    Iterable<dynamic> users = item.registeredUsers!;

    for (var user in users) {
      if (user.toString() == userEmail) {
        print('event is already owned');
        return true;
      }
    }
    print("event is not owned");
    return false;
  }

  int getDateTimeInt() {
    int val = int.parse(item.date.toString());
    print('int date time = ' + val.toString());
    return val;
  }

  int getCurrentDateTimeInt() {
    DateTime now = DateTime.now();
    int val = int.parse(now.year.toString() +
        (now.month > 9 ? now.month.toString() : '0' + now.month.toString()) +
        (now.day > 9 ? now.day.toString() : '0' + now.day.toString()) +
        (now.hour > 9 ? now.hour.toString() : '0' + now.hour.toString()) +
        (now.minute > 9 ? now.minute.toString() : '0' + now.minute.toString()));
    print('current int date time = $val');
    return val;
  }

  _SingleEventScreenState({required this.item});
  SpeakersList speakersList = new SpeakersList(
    speakers: ["SPEAKERS LOADING"],
  );
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Constants.blueThemeColor,
        leading: MaterialButton(
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            refreshEvents == true
                ? Navigator.popAndPushNamed(context, '/events')
                : Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: getDateTimeInt() < getCurrentDateTimeInt() &&
              item.archetype == "Youtube"
          ? SizedBox()
          : RoundedButton(
              title: item.archetype == "Youtube"
                  ? checkOwnedEvent() == true
                      ? "Open Livesteam Link"
                      : "Add To Calendar"
                  : item.archetype == "MS Teams"
                      ? (getDateTimeInt() < getCurrentDateTimeInt())
                          ? 'Recording Not Available'
                          : (item.isMembersOnly == true &&
                                  MemberChecker().checkIfMember(userEmail) ==
                                      false)
                              ? 'Members Only'
                              : checkOwnedEvent() == true
                                  ? 'Open Teams Link'
                                  : 'Sign Up for Teams Event'
                      : "" //impliment for paid event
              ,
              onPressed: () {
                if (item.archetype == "MS Teams" &&
                    getDateTimeInt() < getCurrentDateTimeInt()) {
                  return null;
                }
                if (item.isMembersOnly == true &&
                    MemberChecker().checkIfMember(userEmail) == false) {
                  return null;
                }
                if (item.archetype == "Youtube" ||
                    item.archetype == "MS Teams") {
                  if (checkOwnedEvent()) {
                    return EventRegisterComponents.openURL(item);
                  }
                  return showDialog(
                      context: context,
                      builder: (context) {
                        bool isLoading = false;
                        return AlertDialog(
                          title: Row(
                            children: [Text("Complete Registration")],
                          ),
                          content: Row(
                            children: [
                              Text("Add to device calendar: "),
                              Checkbox(
                                value: addtoCalendarBool,
                                onChanged: (val) {
                                  setState(() {
                                    addtoCalendarBool = val;
                                  });
                                },
                              ),
                            ],
                          ),
                          actions: [
                            MaterialButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                            MaterialButton(
                                child: Text("Proceed"),
                                onPressed: () async {
                                  setState(() {
                                    Dialogs.showLoadingDialog(
                                        context, _keyLoader);
                                    print(
                                        "is loading = " + isLoading.toString());
                                  });
                                  print('attempting to update user');
                                  await EventRegisterComponents.updateUser(
                                      item.id);
                                  print('attempting to update event');
                                  await EventRegisterComponents.updateEvent(
                                      item.id);
                                  await EventRegisterComponents.sendEmail(item);
                                  if (addtoCalendarBool == true) {
                                    EventRegisterComponents.addToCalendar(item);
                                  }
                                  var store = FirebaseFirestore.instance;
                                  var doc = await store
                                      .collection("Events")
                                      .doc(item.id)
                                      .get();
                                  var data = doc.data();

                                  setState(() {
                                    refreshEvents = true;
                                    item = EventsStream.getItem(data!, item.id);
                                    item.showInfo = true;
                                    item.hideSummary = true;
                                    if (item.archetype == "Youtube")
                                      item.showVid = true;
                                    item.isButton = false;
                                  });
                                  Navigator.of(_keyLoader.currentContext!,
                                          rootNavigator: true)
                                      .pop();

                                  isLoading = false;
                                  await _alertDialogBuilder("Finished",
                                      "Thank you for registering for ${item.title}, please check your email (and spam) for more info!",
                                      () {
                                    Navigator.pop(context);
                                  });

                                  Navigator.pop(context);
                                }),
                          ],
                        );
                      });
                } else {
                  EventRegisterComponents.openURL(item);
                }

                // Navigator.push(
                //   //push with price and event ID
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => EventRegisterScreen(
                //       id: item.id,
                //       eventItem: item,
                //       isEventAlreadyOwned: checkOwnedEvent(),
                //       isPastEvent: getDateTimeInt() < getCurrentDateTimeInt(),
                //     ),
                //   ),
                // );
              },
              radius: 10,
              width: 350,
              colour: Constants.blueThemeColor,
              textStyle: TextStyle(color: Colors.white),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          item,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlatButton(
                  onPressed: () {
                    setState(() {
                      isInfoActive = true;
                    });
                  },
                  child: Container(
                    child: Text('Info'),
                    decoration:
                        isInfoActive ? activeDecoration : inActiveDecoration,
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      isInfoActive = false;
                    });
                  },
                  child: Container(
                    child: Text('Speakers'),
                    decoration:
                        isInfoActive ? inActiveDecoration : activeDecoration,
                  ),
                ),
              ],
            ),
          ),
          isInfoActive
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(item.info!),
                )
              : speakersList,
          SizedBox(
            height: 150,
          )
        ],
      ),
    );
  }
}

class SpeakersList extends StatelessWidget {
  final List speakers;
  SpeakersList({required this.speakers});
  List<SpeakerItem> speakerItemList = [];
  void generateSpeakers() {
    print('speaekrs 2 = $speakers');
    for (String s in speakers) {
      speakerItemList.add(SpeakerItem(
        title: s,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: speakerItemList,
      ),
    );
  }
}

class SpeakerItem extends StatelessWidget {
  final String? title;
  SpeakerItem({this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Text(
        '- $title',
        style: TextStyle(color: Constants.darkBlueThemeColor, fontSize: 20),
      ),
    );
  }
}
