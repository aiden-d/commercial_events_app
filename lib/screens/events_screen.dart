import 'package:amcham_app_v2/constants.dart';
import 'package:amcham_app_v2/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amcham_app_v2/components/rounded_button.dart';
import 'package:amcham_app_v2/components/bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'single_event_screen.dart';
import 'package:amcham_app_v2/components/get_firebase_image.dart';
import 'package:amcham_app_v2/components/event_item.dart';
import 'package:amcham_app_v2/scripts/member_checker.dart';

final _firestore = Firestore.instance;
firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  static var test;
  int _selectedIndex = 0;
  Container eventItems = Container();
  bool isPastEvents = false;
  bool isMyEvents = false;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void getData() async {
    _firestore
        .collection('Events')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                print(doc["title"]);
              })
            });
  }

  @override
  void initState() {
    getData();
    getIfMember();
    super.initState();
  }

  MemberChecker memberChecker = new MemberChecker();
  Future<void> getIfMember() async {
    String email = FirebaseAuth.instance.currentUser.email;
    await memberChecker.updateEndings();
  }

  printMember() {
    String email = FirebaseAuth.instance.currentUser.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBar(),
      appBar: AppBar(
        backgroundColor: Constants.blueThemeColor,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: isPastEvents != true
                        ? Constants.darkBlueThemeColor
                        : Constants.blueThemeColor,
                  ),
                  child: MaterialButton(
                    child: Text(
                      'Upcoming Events',
                      style: Constants.whiteTextStyle,
                    ),
                    onPressed: () {
                      setState(() {
                        isPastEvents = false;
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: isPastEvents == true
                        ? Constants.darkBlueThemeColor
                        : Constants.blueThemeColor,
                  ),
                  child: MaterialButton(
                    child: Text(
                      'Past Events',
                      style: Constants.whiteTextStyle,
                    ),
                    onPressed: () {
                      setState(() {
                        isPastEvents = true;
                      });
                    },
                  ),
                ),
              ),
              //TODO add categories
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Container(
              //     height: 30,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(15),
              //       color: Constants.blueThemeColor,
              //     ),
              //     child: IconButton(
              //       icon: Icon(
              //         Icons.format_list_bulleted,
              //         color: Colors.white,
              //         size: 20,
              //       ),
              //       onPressed: () {},
              //     ),
              //   ),
              // ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: isMyEvents != true
                        ? Constants.darkBlueThemeColor
                        : Constants.blueThemeColor,
                  ),
                  child: MaterialButton(
                    child: Text(
                      'All Events',
                      style: Constants.whiteTextStyle,
                    ),
                    onPressed: () {
                      setState(() {
                        isMyEvents = false;
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: isMyEvents == true
                        ? Constants.darkBlueThemeColor
                        : Constants.blueThemeColor,
                  ),
                  child: MaterialButton(
                    child: Text(
                      'My Events',
                      style: Constants.whiteTextStyle,
                    ),
                    onPressed: () {
                      setState(() {
                        isMyEvents = true;
                      });
                    },
                  ),
                ),
              ),
              //TODO add categories
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Container(
              //     height: 30,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(15),
              //       color: Constants.blueThemeColor,
              //     ),
              //     child: IconButton(
              //       icon: Icon(
              //         Icons.format_list_bulleted,
              //         color: Colors.white,
              //         size: 20,
              //       ),
              //       onPressed: () {},
              //     ),
              //   ),
              // ),
            ],
          ),
          Expanded(
            child: Container(
              //height: MediaQuery.of(context).size.height - SizeConfig().getBlockSizeVertical() * 22,
              child: isMyEvents == true
                  ? (isPastEvents != true
                      ? EventsStream(
                          isPastEvents: false,
                          isMyEvents: true,
                        )
                      : EventsStream(
                          isPastEvents: true,
                          isMyEvents: true,
                        ))
                  : isPastEvents != true
                      ? EventsStream(
                          isPastEvents: false,
                          isMyEvents: false,
                        )
                      : EventsStream(
                          isPastEvents: true,
                          isMyEvents: false,
                        ),
              // child: ListView(
              //   padding: const EdgeInsets.all(8),
              //   children: [
              //     EventItem(
              //         price: 0,
              //         date: 20040831,
              //         title: 'ThanksGving',
              //         type: 'Livestream',
              //         category: 'Special Events',
              //         isMembersOnly: false,
              //         summary: 'kldnaw kdwnak ndwandkawkld kwakoldn')
              //   ],
              // ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventsStream extends StatelessWidget {
  CollectionReference eventsRef = _firestore.collection('Events');
  final bool isPastEvents;
  final bool isMyEvents;
  EventsStream({@required this.isPastEvents, @required this.isMyEvents});

  EventItem getItem(Map<String, dynamic> data, String id) {
    return new EventItem(
      price: data['price'],
      date: data['date'],
      title: data['title'],
      type: data['type'],
      category: data['category'],
      isMembersOnly: data['isMembersOnly'],
      summary: data['summary'],
      imageRef: data['image_name'],
      info: data['info'],
      id: id,
      link: data['link'],
      registeredUsers: data['registered_users'],
      endTime: data['end_time'],
      startTime: data['start_time'],
    );
  }

  bool getIfMyEvent(Map<String, dynamic> data) {
    String userEmail = FirebaseAuth.instance.currentUser.email;
    List registeredUsers = data['registered_users'];

    if (registeredUsers == null) return false;
    for (var ru in registeredUsers) {
      if (ru == userEmail) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: eventsRef.get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          List<EventItem> eventItems = [];
          var events = snapshot.data.docs;
          for (var event in events) {
            Map<String, dynamic> data = event.data();
            int eventDate = data['date'];
            DateTime now = new DateTime.now();
            DateTime date = new DateTime(now.year, now.month, now.day);
            String dateString = '${date.year}${date.month}${date.day}';
            int dateInt = int.parse(dateString);
            if (isMyEvents) {
              if (getIfMyEvent(data) == true) {
                if (isPastEvents == true) {
                  if (eventDate <= dateInt) {
                    EventItem eventItem = getItem(data, event.id);
                    eventItems.add(eventItem);
                  }
                } else {
                  if (eventDate >= dateInt) {
                    EventItem eventItem = getItem(data, event.id);
                    eventItems.add(eventItem);
                  }
                }
              }
            } else if (isPastEvents == true) {
              if (eventDate <= dateInt) {
                EventItem eventItem = getItem(data, event.id);
                eventItems.add(eventItem);
              }
            } else {
              if (eventDate >= dateInt) {
                EventItem eventItem = getItem(data, event.id);
                eventItems.add(eventItem);
              }
            }
          }

          if (isPastEvents == true) {
            int size = eventItems.length;
            if (size > 1) {
              bool isNotSorted = true;
              while (isNotSorted) {
                isNotSorted = false;
                int i = 0;
                while (i + 1 < size) {
                  if (eventItems[i].date < eventItems[i + 1].date) {
                    var temp = eventItems[i + 1];
                    eventItems[i + 1] = eventItems[i];
                    eventItems[i] = temp;
                    isNotSorted = true;
                  }
                  i += 1;
                  print('running');
                }
              }
            }
          } else {
            int size = eventItems.length;
            if (size > 1) {
              bool isNotSorted = true;
              while (isNotSorted) {
                isNotSorted = false;
                int i = 0;
                while (i + 1 < size) {
                  if (eventItems[i].date > eventItems[i + 1].date) {
                    var temp = eventItems[i + 1];
                    eventItems[i + 1] = eventItems[i];
                    eventItems[i] = temp;
                    isNotSorted = true;
                  }
                  i += 1;
                  print('running');
                }
              }
            }
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: eventItems,
            ),
          );
        }
        return Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.lightBlueAccent,
          ),
        );
      },
    );
  }
}
