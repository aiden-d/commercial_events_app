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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBar(),
      appBar: AppBar(
        backgroundColor: Constants.blueThemeColor,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              //height: MediaQuery.of(context).size.height - SizeConfig().getBlockSizeVertical() * 22,
              child: EventsStream(),
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
            //TODO make category for past events
            if (eventDate >= dateInt) {
              EventItem eventItem = new EventItem(
                price: data['price'],
                date: data['date'],
                title: data['title'],
                type: data['type'],
                category: data['category'],
                isMembersOnly: data['isMembersOnly'],
                summary: data['summary'],
                imageRef: data['image_name'],
                info: data['info'],
                id: event.id,
                link: data['link'],
                registeredUsers: data['registered_users'],
                endTime: data['end_time'],
                startTime: data['start_time'],
              );
              eventItems.add(eventItem);
            }
          }
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

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: eventItems,
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
