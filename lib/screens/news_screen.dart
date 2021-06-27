import 'dart:io';

import 'package:amcham_app_v2/components/news_item.dart';
import 'package:amcham_app_v2/constants.dart';
import 'package:amcham_app_v2/screens/single_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:amcham_app_v2/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:amcham_app_v2/components/bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:web_browser/web_browser.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:amcham_app_v2/components/search_app_bar.dart';
import 'package:amcham_app_v2/components/hashing.dart';

class UpdatesScreen extends StatefulWidget {
  @override
  _UpdatesScreenState createState() => _UpdatesScreenState();
}

final _firestore = Firestore.instance;

class _UpdatesScreenState extends State<UpdatesScreen> {
  @override
  void initState() {
    SearchAppbar.searchString = "";
    // TODO: implement initState
    super.initState();
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
      body: Container(
          child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Text(
              "News",
              style: Constants.logoTitleStyle.copyWith(color: Colors.black),
            ),
            NewsStream(isSearching: isSearching, searchHash: searchHash)
          ],
        ),
      )),
      bottomNavigationBar: BottomBar(),
    );
  }
}

bool isSearching = false;
List<int> searchHash = [];
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

class NewsStream extends StatelessWidget {
  CollectionReference newsRef = _firestore.collection('News');

  final bool isSearching;
  final List<int> searchHash;

  NewsStream({@required this.isSearching, @required this.searchHash});

  NewsItem getItem(Map<String, dynamic> data, String id) {
    print('id = $id');
    print(data);
    return new NewsItem(
      link: data['link'],
      title: data['title'],
      dateTime: data['date_time'],
      summaryText: data['summary_text'],
      imageRef: data['image_name'],
      info: data['info'],
      id: id,
      tier1hashes: data['tier_1_hashes'],
      tier2hashes: data['tier_2_hashes'],
      tier3hashes: data['tier_3_hashes'],
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
      future: newsRef.get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          List<NewsItem> newsItems = [];
          var newsDocs = snapshot.data.docs;
          for (var news in newsDocs) {
            Map<String, dynamic> data = news.data();
            int newsDate = data['date'];
            DateTime now = new DateTime.now();
            DateTime date = new DateTime(now.year, now.month, now.day);
            String dateString = '${date.year}${date.month}${date.day}';
            int dateInt = int.parse(dateString);
            NewsItem newsItem = getItem(data, news.id);
            newsItems.add(newsItem);
          }
          if (isSearching == true) {
            for (NewsItem e in newsItems) {
              if (searchHash == null) {
                print('search hashes  null');
              }
              e.getPointsFromHashes(searchHash);
            }
            int size = newsItems.length;

            bool isNotSorted = true;
            while (isNotSorted) {
              isNotSorted = false;
              int i = 0;
              while (i < size) {
                if (newsItems[i].rankedPoints == 0) {
                  newsItems.remove(newsItems[i]);
                  size = newsItems.length;
                  i = -1;
                } else if (i < size - 1) {
                  if (newsItems[i].rankedPoints <
                      newsItems[i + 1].rankedPoints) {
                    var temp = newsItems[i + 1];
                    newsItems[i + 1] = newsItems[i];
                    newsItems[i] = temp;
                    isNotSorted = true;
                  }
                }
                i += 1;
              }
            }
          } else {
            int size = newsItems.length;
            if (size > 1) {
              bool isNotSorted = true;
              while (isNotSorted) {
                isNotSorted = false;
                int i = 0;
                while (i + 1 < size) {
                  if (newsItems[i].dateTime < newsItems[i + 1].dateTime) {
                    var temp = newsItems[i + 1];
                    newsItems[i + 1] = newsItems[i];
                    newsItems[i] = temp;
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
              children: newsItems,
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
