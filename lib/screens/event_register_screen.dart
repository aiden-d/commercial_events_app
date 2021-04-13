import 'dart:async';
import 'dart:ui';

import 'package:url_launcher/url_launcher.dart';
import 'package:amcham_app_v2/components/event_item.dart';
import 'package:amcham_app_v2/constants.dart';
import 'package:flutter/material.dart';
import 'package:amcham_app_v2/components/rounded_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:amcham_app_v2/size_config.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:web_browser/web_browser.dart';
import 'events_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_web_browser/flutter_web_browser.dart';

class EventRegisterScreen extends StatefulWidget {
  final EventItem eventItem;
  final String id;
  final bool isEventAlreadyOwned;
  EventRegisterScreen({
    @required this.id,
    @required this.eventItem,
    @required this.isEventAlreadyOwned,
  });
  @override
  _EventRegisterScreenState createState() => _EventRegisterScreenState(
        id: id,
        eventItem: eventItem,
        isEventAlreadyOwned: isEventAlreadyOwned,
      );
}

class _EventRegisterScreenState extends State<EventRegisterScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final EventItem eventItem;
  final String id;
  final bool isEventAlreadyOwned;

  _EventRegisterScreenState(
      {@required this.id,
      @required this.eventItem,
      @required this.isEventAlreadyOwned});
  bool isTopLoading = false;
  bool isMidLoading = false;
  bool isBottomLoading = false;
  String fullURL = "";
  bool showBrowser = false;
  CollectionReference userInfo =
      FirebaseFirestore.instance.collection('UserInfo');
  CollectionReference eventsInfo =
      FirebaseFirestore.instance.collection('Events');
  String userEmail = FirebaseAuth.instance.currentUser.email;

  bool isThereDuplicate(List<dynamic> array, var itemToCheck) {
    for (var item in array) {
      if (item == itemToCheck) {
        return true;
      }
      return false;
    }
    return false;
  }

  Future<void> updateUser() async {
    List<dynamic> ownedEvents;

//TODO validate so there is no duplicates
    await userInfo
        .doc(userEmail)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        ownedEvents = documentSnapshot.data()['owned_events'];
        if (ownedEvents != null) {
          if (isThereDuplicate(ownedEvents, id)) {
            print('User already added');
            return null;
            //TODO show error
          } else {
            ownedEvents.add(id);
          }
        } else {
          ownedEvents = [id];
        }
      } else {
        print('an error occured');
        //TODO show error
        return;
      }
    });

    return userInfo
        .doc(userEmail)
        .update({'owned_events': ownedEvents})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future<void> updateEvent() async {
    String userEmail = FirebaseAuth.instance.currentUser.email;
    List<dynamic> registeredUsers;

//TODO validate so there is no duplicates
    await eventsInfo.doc(id).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        registeredUsers = documentSnapshot.data()['registered_users'];
        if (registeredUsers != null) {
          if (isThereDuplicate(registeredUsers, userEmail)) {
            print('User already added');
            return null;
          } else {
            registeredUsers.add(userEmail);
          }
        } else {
          registeredUsers = [userEmail];
        }
      } else {
        print('an error occured');
        //TODO show error
        return;
      }
    });

    return eventsInfo
        .doc(id)
        .update({'registered_users': registeredUsers})
        .then((value) => print("Events Updated"))
        .catchError((error) => print("Failed to update events: $error"));
  }

  Future<void> sendEmail() async {
    int dateInt = eventItem.date;
    int timeInt = eventItem.startTime;
    String date = eventItem.DateToString(dateInt) +
        ' at ' +
        eventItem.TimeToString(timeInt);
    var res = await http.get(
        'https://us-central1-amcham-app.cloudfunctions.net/sendMail?dest=$userEmail&subject=Thank you for signing up for ${eventItem.title}&message=Thank you for signing up for <b> ${eventItem.title}  </br> <br>Please access the event on the date: <b> $date </b> </b> <br><br> <b> With the link (if clicking on the link does not work please copy and paste it into the browser): </b> <br> <a href="${eventItem.link}">This Link</a></b><br></br>${eventItem.link}');
    print(res.body);
    
  }

  _launchURL() async {
    String url = eventItem.link;
    
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void addToCalendar() async {
    Event event = Event(
      title: eventItem.title,
      description: '${eventItem.link}',
      startDate: getDateFromItem(eventItem.startTime),
      endDate: getDateFromItem(eventItem.endTime),
    );
    print('adding to calendar');
    await Add2Calendar.addEvent2Cal(event);
    print('added to calendar');
    return;
  }

  DateTime getDateFromItem(int time) {
    String dateStr = eventItem.date.toString();
    String timeStr =
        time.toString().length >= 4 ? time.toString() : '0' + time.toString();
    int year = int.parse(dateStr.substring(0, 4));
    int month = int.parse(dateStr.substring(4, 6));
    int day = int.parse(dateStr.substring(6, 8));
    int hour = int.parse(timeStr.substring(0, 2));
    int minute = int.parse(timeStr.substring(2, 4));

    //TODO add time
    return new DateTime(year, month, day, hour, minute);
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _alertDialogBuilder(String title, String info, Function closeFunction) async {
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
                  onPressed: closeFunction!=null ? closeFunction :  () {
                    Navigator.pop(context);
                  },
                  child: Text("Close Dialog"))
            ],
          );
        });
  }

  String getPriceString() {
    if (eventItem.price > 0) {
      return 'R${eventItem.price}';
    }
    return 'FREE';
  }

  Future<void> pay() async {
    String userEmailString = '';
    for (int i = 0; i < userEmail.length; i++) {
      var char = userEmail[i];
      if (char == '@') {
        userEmailString += "%40";
      } else {
        userEmailString += char;
      }
    }
    var res = await http.get(
        'https://us-central1-amcham-app.cloudfunctions.net/genkey?user=$userEmailString');
    var userKey = res.body;
    

    

    String link =
        "https://us-central1-amcham-app.cloudfunctions.net/registerUser?user=$userKey%26eventID=${eventItem.id}";

    print(link);
    fullURL =
        "https://sandbox.payfast.co.za/eng/process?cmd=_paynow&receiver=10022223&item_name=test+payment&amount=69.00&return_url=$link";
    
    await userInfo.doc(userEmail).update({"successful_transaction":false,});
    setState(() {
      showBrowser = true;
    });

    Timer.periodic(Duration(seconds: 2), (timer) async {
      var data  = await userInfo.doc(userEmail).get();
      if (data["successful_transaction"]==true){
        setState(() {
          showBrowser = false;
          timer.cancel();
        });
        if (addtoCalendarBool){
          await addToCalendar();
        }
        await _alertDialogBuilder('Payment Success!', 'Thank you for your purchase, you can now access the info by clicking on the event', (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> EventsScreen()));});

      }
      if (showBrowser == false){
        timer.cancel();
        
      }
    });
    setState(() {
      isBottomLoading = false;
    });
  }

  bool addtoCalendarBool = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.blueThemeColor,
      appBar: isEventAlreadyOwned == true
          ? AppBar(
              backgroundColor: Constants.blueThemeColor,
            )
          : null,
      //TODO impliment IAP system
      body: Center(
        child: isEventAlreadyOwned != true
            ? showBrowser == true
                ? SafeArea(
                    child: WebBrowser(
                    initialUrl: fullURL,
                    javascriptEnabled: true,
                    interactionSettings: WebBrowserInteractionSettings(
                        topBar: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 40,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  showBrowser = false;
                                });
                              },
                            ),
                          ),
                        ),
                        bottomBar: null),
                  ))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 40,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        '${eventItem.title}: ${getPriceString()}',
                        style: Constants.logoTitleStyle,
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical * 8,
                      ),
                      Text(
                        eventItem.price == 0
                            ? ''
                            : 'Note: You may be redirected to pay (do not leave the page after paying)',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical * 2,
                      ),
                      kIsWeb == true
                          ? SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    unselectedWidgetColor: Colors.white,
                                  ),
                                  child: Checkbox(
                                    value: addtoCalendarBool,
                                    onChanged: (val) {
                                      setState(() {
                                        addtoCalendarBool = val;
                                      });
                                    },
                                  ),
                                ),
                                Text(
                                  'Add Event To Device Calendar?',
                                  style: Constants.whiteTextStyle
                                      .copyWith(fontSize: 20),
                                )
                              ],
                            ),
                      RoundedButton(
                          isLoading: isBottomLoading,
                          title: 'Complete Registration',
                          onPressed: () async {
                            setState(() {
                              isBottomLoading = true;
                            });
                            if (eventItem.price > 0) {
                              await pay();

                              // await FlutterWebBrowser.openWebPage(
                              //   url: fullURL,
                              //   customTabsOptions: CustomTabsOptions(
                              //     urlBarHidingEnabled: true,
                              //     addDefaultShareMenuItem: false,
                              //     showTitle: false,
                              //   ),
                              // );
                              // Navigator.pushReplacement(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => EventsScreen()));

                              return;
                            } else {
                              //add event ID to user account storage on firebase
                              print('attempting to update user');
                              await updateUser();
                              print('attempting to update event');
                              await updateEvent();
                              print('sending email');
                            }

                            await sendEmail();
                            if (addtoCalendarBool == true) {
                              await addToCalendar();
                            }
                            await _alertDialogBuilder('Sent',
                                'Check your email or calendar to access the event', null);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventsScreen(),
                                ));

                            //send email and pop to previous screen

                            setState(() {
                              isBottomLoading = false;
                            });
                          }),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical * 20,
                      ),
                    ],
                  )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Align(
                  //   alignment: Alignment.topLeft,
                  //   child: IconButton(
                  //     icon: Icon(
                  //       Icons.arrow_back,
                  //       size: 100,
                  //       color: Colors.white,
                  //     ),
                  //     onPressed: () {
                  //       Navigator.pop(context);
                  //     },
                  //   ),
                  // ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'You have already registered for this event',
                      style: Constants.logoTitleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  RoundedButton(
                    title: 'Resend email',
                    isLoading: isTopLoading,
                    onPressed: () async {
                      setState(() {
                        isTopLoading = true;
                      });
                      //add event ID to user account storage on firebase

                      print('sending email');
                      await sendEmail();

                      //send email and pop to previous screen

                      setState(() {
                        isTopLoading = false;
                      });
                    },
                  ),
                  RoundedButton(
                    title: 'Open Link',
                    isLoading: isMidLoading,
                    onPressed: _launchURL,
                  ),
                  RoundedButton(
                    title: 'Add to calendar',
                    isLoading: isBottomLoading,
                    onPressed: () async {
                      setState(() {
                        isBottomLoading = true;
                      });
                      //add event ID to user account storage on firebase

                      print('adding to calendar');
                      addToCalendar();

                      //send email and pop to previous screen

                      setState(() {
                        isBottomLoading = false;
                      });
                    },
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 15,
                  ),
                ],
              ),
      ),
    );
  }
}
