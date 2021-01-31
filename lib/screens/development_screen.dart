import 'package:flutter/material.dart';

class DevelopmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

//web browser for payments
// return Scaffold(
// bottomNavigationBar: BottomBar(),
// body: SafeArea(
// child: WebBrowser(
// interactionSettings: WebBrowserInteractionSettings(
// gestureNavigationEnabled: false,
// bottomBar: WebBrowserNavigationBar(
// backButton: null,
// forwardButton: null,
// ),
// topBar: null,
// ),
// initialUrl: 'https://flutter.dev/',
// javascriptEnabled: true,
// ),
// ),
// );

//notification testing
// return Scaffold(
//   appBar: AppBar(
//     title: Text(this.messageTitle),
//   ),
//   body: Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         Text(
//           notificationAlert,
//         ),
//         Text(
//           messageTitle,
//           style: Theme.of(context).textTheme.headline4,
//         ),
//       ],
//     ),
//   ),
// );

// String messageTitle = "Empty";
// String notificationAlert = "alert";
//
// FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
// _firebaseMessaging.configure(
// onMessage: (message) async {
// setState(() {
// messageTitle = message["notification"]["title"];
// notificationAlert = "New Notification Alert";
// });
// },
// onResume: (message) async {
// setState(() {
// messageTitle = message["data"]["title"];
// notificationAlert = "Application opened from Notification";
// });
// },
// );
