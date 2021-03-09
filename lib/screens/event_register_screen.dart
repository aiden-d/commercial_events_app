import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:amcham_app_v2/components/event_item.dart';
import 'package:amcham_app_v2/constants.dart';
import 'package:flutter/material.dart';
import 'package:amcham_app_v2/components/rounded_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:amcham_app_v2/size_config.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'events_screen.dart';
import 'package:http/http.dart' as http;

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
    // String username = 'amchamsa.events@gmail.com';
    // String password = '31Bextonlane#';
    //
    // final smtpServer = gmail(username, password);
    // // Creating the Gmail server
    //
    // // Create our email message.
    // final message = Message()
    //   ..from = Address(username, 'Amcham Events')
    //   ..recipients.add(userEmail) //recipent email
    //   ..subject =
    //       'Thank you for signing up for ${eventItem.title}' //subject of the email
    //   ..text =
    //       'Thank you for signing up for ${eventItem.title}\nPlease acess the event at the date..... with the link: ${eventItem.link}'; //body of the email
    //
    // try {
    //   final sendReport = await send(message, smtpServer);
    //   print('Message sent: ' +
    //       sendReport.toString()); //print if the email is sent
    // } on MailerException catch (e) {
    //   print('Message not sent. \n' +
    //       e.toString()); //print if the email is not sent
    //   // e.toString() will show why the email is not sending
    // }
  }

  _launchURL() async {
    String url = eventItem.link;
    print('url = $url');
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void addToCalendar() {
    Event event = Event(
      title: eventItem.title,
      description: '${eventItem.link}',
      startDate: getDateFromItem(eventItem.startTime),
      endDate: getDateFromItem(eventItem.endTime),
    );
    Add2Calendar.addEvent2Cal(event);
    return;
  }

  DateTime getDateFromItem(int time) {
    String dateStr = eventItem.date.toString();
    String timeStr = time.toString();
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

  Future<void> _alertDialogBuilder(String title, String info) async {
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Close Dialog"))
            ],
          );
        });
  }

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
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Registration Successful!',
                    style: Constants.logoTitleStyle,
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 8,
                  ),
                  Text(
                    'How would you like to receive the link?',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  RoundedButton(
                    title: 'Only Email',
                    isLoading: isTopLoading,
                    onPressed: () async {
                      setState(() {
                        isTopLoading = true;
                      });
                      //add event ID to user account storage on firebase
                      print('attempting to update user');
                      await updateUser();
                      print('attempting to update event');
                      await updateEvent();
                      print('sending email');
                      await sendEmail();
                      await _alertDialogBuilder(
                          'Sent', 'Check your email to access the event');
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventsScreen(),
                          ));

                      //send email and pop to previous screen

                      setState(() {
                        isTopLoading = false;
                      });
                    },
                  ),
                  RoundedButton(
                    title: 'Email + Calendar',
                    isLoading: isBottomLoading,
                    onPressed: () async {
                      setState(() {
                        isBottomLoading = true;
                      });
                      //add event ID to user account storage on firebase
                      print('attempting to update user');
                      await updateUser();
                      print('attempting to update event');
                      await updateEvent();
                      print('sending email');
                      await sendEmail();
                      await addToCalendar();
                      await _alertDialogBuilder('Sent',
                          'Check your email or calendar to access the event');
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventsScreen(),
                          ));

                      //send email and pop to previous screen

                      setState(() {
                        isBottomLoading = false;
                      });
                    },
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 20,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
