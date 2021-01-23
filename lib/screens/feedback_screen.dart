import 'package:amcham_app_v2/components/alert_dialog_builder.dart';
import 'package:amcham_app_v2/components/rounded_button.dart';
import 'package:amcham_app_v2/components/rounded_text_field.dart';
import 'package:amcham_app_v2/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  bool isBug = false;
  String message = '';
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("lib/images/TreeBackground.png"),
              fit: BoxFit.cover)),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  child: IconButton(
                    padding: EdgeInsets.all(5),
                    iconSize: 40,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      CupertinoIcons.arrow_left,
                      color: Colors.white,
                    ),
                  ),
                  alignment: Alignment.topLeft,
                ),
                Center(
                  child: Text(
                    'Have Feedback?',
                    style: Constants.logoTitleStyle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Type: ',
                          style: Constants.logoTitleStyle
                              .copyWith(color: Colors.black, fontSize: 16),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Bug:'),
                        Checkbox(
                            value: isBug,
                            onChanged: (value) {
                              setState(() {
                                isBug = true;
                              });
                            }),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Feedback:'),
                        Checkbox(
                            value: !isBug,
                            onChanged: (value) {
                              setState(() {
                                isBug = false;
                              });
                            }),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white),
                    height: 300,
                    width: double.infinity,
                    child: Align(
                      child: CupertinoTextField(
                        onChanged: (value) {
                          message = value;
                        },
                        placeholder: 'Enter feedback...',
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                      alignment: Alignment.topLeft,
                    ),
                  ),
                ),
                RoundedButton(
                    isLoading: isLoading,
                    title: 'Submit',
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      if (message != null && message != '') {
                        var v = await http.get(
                            'https://us-central1-amcham-app.cloudfunctions.net/sendMail?dest=aidendawes@gmail.com&subject=New ${isBug == true ? 'Bug' : 'Feedback'} reported&message=$message');
                        print(v.body);
                        return showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Sent"),
                                content: Container(
                                  child: Text("Thanks for the feedback!"),
                                ),
                                actions: [
                                  FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text("Close")),
                                ],
                              );
                            });
                      }
                      setState(() {
                        isLoading = false;
                      });

                      Navigator.pop(context);
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
