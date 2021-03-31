import 'package:amcham_app_v2/components/rounded_text_field.dart';
import 'package:amcham_app_v2/components/search_app_bar.dart';
import 'package:amcham_app_v2/constants.dart';
import 'package:amcham_app_v2/hash_table.dart';
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
import 'dart:convert';
import 'package:amcham_app_v2/components/hashing.dart';

final _firestore = Firestore.instance;
firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int _selectedIndex = 0;
  Container eventItems = Container();
  bool isPastEvents = false;
  bool isMyEvents = false;
  bool isSearching = false;
  List<int> searchHash = [];

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

  List<String> seperateWords(String str) {
    if (str == '') {
      print('string cannot be null');
      return [''];
    }

    String strCopy = str.trim();
    int start = 0;
    int i = 0;
    int len = strCopy.length;
    List<String> words = [];
    while (i < len) {
      if (strCopy[i] == ' ') {
        words.add(strCopy.substring(start, i));
        strCopy = strCopy.substring(i + 1, strCopy.length);
        len = strCopy.length;
        i = 0;
      } else {
        i++;
      }
    }
    words.add(strCopy);
    return words;
  }

  void search(String _searchString) {
    String searchStr = _searchString.trim();
    searchHash = [];
    if (searchStr == '' || searchStr == null) {
      isSearching = false;
      return;
    }
    List<int> searchHashes = [];
    List<String> words = seperateWords(searchStr);
    for (String w in words) {
      int hash = generateSimpleHash(w.toLowerCase());
      print('hash = $hash');
      searchHashes.add(hash);
    }
    setState(() {
      //print('real search hashes' + searchHashes.toString());
      searchHash = searchHashes;
      isSearching = true;
    });
  }

  void clearSearch() {
    setState(() {
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBar(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: SearchAppbar(
          searchFunction: (value) {
            search(value);
          },
          clearFunction: () {
            clearSearch();
          },
        ),
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
          Container(
            //height: MediaQuery.of(context).size.height - SizeConfig().getBlockSizeVertical() * 22,
            child: isMyEvents == true
                ? (isPastEvents != true
                    ? EventsStream(
                        isPastEvents: false,
                        isMyEvents: true,
                        searchHash: searchHash,
                        isSearching: isSearching,
                      )
                    : EventsStream(
                        isPastEvents: true,
                        isMyEvents: true,
                        searchHash: searchHash,
                        isSearching: isSearching,
                      ))
                : isPastEvents != true
                    ? EventsStream(
                        isPastEvents: false,
                        isMyEvents: false,
                        searchHash: searchHash,
                        isSearching: isSearching,
                      )
                    : EventsStream(
                        isPastEvents: true,
                        isMyEvents: false,
                        searchHash: searchHash,
                        isSearching: isSearching,
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
        ],
      ),
    );
  }
}

class EventsStream extends StatelessWidget {
  CollectionReference eventsRef = _firestore.collection('Events');
  final bool isPastEvents;
  final bool isMyEvents;
  final bool isSearching;
  final List<int> searchHash;

  EventsStream(
      {@required this.isPastEvents,
      @required this.isMyEvents,
      @required this.isSearching,
      @required this.searchHash});

  EventItem getItem(Map<String, dynamic> data, String id) {
    return new EventItem(
      pastLink: data['past_link'],
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
      tier1hashes: data['tier_1_hashes'],
      tier2hashes: data['tier_2_hashes'],
      tier3hashes: data['tier_3_hashes'],
      tier4hashes: data['tier_4_hashes'],
      speakers: data['speakers'],
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

//
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
            int dateInt = getCurrentDateTimeInt();
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
          if (isSearching == true) {
            for (EventItem e in eventItems) {
              if (searchHash == null) {
                print('search hashes  null');
              }
              e.getPointsFromHashes(searchHash);
            }
            int size = eventItems.length;

            bool isNotSorted = true;
            while (isNotSorted) {
              isNotSorted = false;
              int i = 0;
              while (i < size) {
                if (eventItems[i].rankedPoints == 0) {
                  eventItems.remove(eventItems[i]);
                  size = eventItems.length;
                  i = -1;
                } else if (i < size - 1) {
                  if (eventItems[i].rankedPoints <
                      eventItems[i + 1].rankedPoints) {
                    var temp = eventItems[i + 1];
                    eventItems[i + 1] = eventItems[i];
                    eventItems[i] = temp;
                    isNotSorted = true;
                  }
                }
                i += 1;
              }
            }
          } else if (isPastEvents == true) {
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
