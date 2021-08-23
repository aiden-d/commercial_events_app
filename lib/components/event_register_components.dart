import 'event_item.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class EventRegisterComponents {
  static openURL(EventItem eventItem) async {
    String? url;
    if (eventItem.archetype == "Youtube") {
      url = eventItem.youtube_link;
    } else {
      url = eventItem.link;
    }

    if (await canLaunch(url!)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static void addToCalendar(EventItem eventItem) async {
    Event event = Event(
      title: eventItem.title!,
      description: eventItem.archetype == "Youtube"
          ? '${eventItem.youtube_link}'
          : '${eventItem.link}',
      startDate: getDateFromItem(eventItem.startTime, eventItem),
      endDate: getDateFromItem(eventItem.endTime, eventItem),
    );
    print('adding to calendar');
    await Add2Calendar.addEvent2Cal(event);
    print('added to calendar');
    return;
  }

  static Future<void> sendEmail(EventItem eventItem) async {
    String? userEmail = FirebaseAuth.instance.currentUser!.email;
    int? dateInt = eventItem.date;
    int? timeInt = eventItem.startTime;
    String date = eventItem.DateToString(dateInt) +
        ' at ' +
        eventItem.TimeToString(timeInt);
    var link = eventItem.archetype == "Youtube"
        ? eventItem.youtube_link
        : eventItem.link;
    var res = await http.get(Uri.parse(
        'https://us-central1-amcham-app.cloudfunctions.net/sendMail?dest=$userEmail&subject=Thank you for signing up for ${eventItem.title}&message=Thank you for signing up for <b> ${eventItem.title}  </br> <br>Please access the event on the date: <b> $date </b> </b> <br><br> <b> With the link (if clicking on the link does not work please copy and paste it into the browser): </b> <br> <a href="${link}">This Link</a></b><br></br>${link}'));
    print(res.body);
  }

  static DateTime getDateFromItem(int? time, EventItem eventItem) {
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

  static Future<void> updateUser(String id) async {
    String? userEmail = FirebaseAuth.instance.currentUser!.email;
    List<dynamic>? ownedEvents;

//TODO validate so there is no duplicates
    var userInfo = FirebaseFirestore.instance.collection("UserInfo");
    await userInfo
        .doc(userEmail)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      if (documentSnapshot.exists) {
        ownedEvents = documentSnapshot.data()!['owned_events'];
        if (ownedEvents != null) {
          if (isThereDuplicate(ownedEvents!, id)) {
            print('User already added');
            return null;
            //TODO show error
          } else {
            ownedEvents!.add(id);
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

  static bool isThereDuplicate(List<dynamic> array, var itemToCheck) {
    for (var item in array) {
      if (item == itemToCheck) {
        return true;
      }
      return false;
    }
    return false;
  }

  static Future<void> updateEvent(String id) async {
    String? userEmail = FirebaseAuth.instance.currentUser!.email;
    List<dynamic>? registeredUsers;
    CollectionReference<Map<String, dynamic>> eventsInfo =
        FirebaseFirestore.instance.collection('Events');

//TODO validate so there is no duplicates
    await eventsInfo
        .doc(id)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      if (documentSnapshot.exists) {
        registeredUsers = documentSnapshot.data()!['registered_users'];
        if (registeredUsers != null) {
          if (isThereDuplicate(registeredUsers!, userEmail)) {
            print('User already added');
            return null;
          } else {
            registeredUsers!.add(userEmail);
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
}
