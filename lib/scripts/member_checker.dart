import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MemberChecker {
  final firestore = FirebaseFirestore.instance;
  final userEmail = FirebaseAuth.instance.currentUser!.email;
  static bool isMember = false;
  static List? emailEndings = [];
//TODO create update endings fucntion
  MemberChecker();
  void main() {
    checkIfMember('aidendawes@gmail.com');
  }

  bool checkIfMember(String? email) {
    if (emailEndings!.length == 0) {
      print('emails ending null');
      return false;
    }
    for (var _end in emailEndings!) {
      String e = _end.toString();
      int start = email!.length - e.length;
      int end = start + e.length;
      String newEnding = email.substring(start, end);
      print(newEnding);
      if (newEnding == e) {
        print('is member');
        isMember = true;
        return true;
      }
    }
    return false;
  }

  Future<void> updateEndings() async {
    FirebaseFirestore.instance
        .collection('Admin')
        .doc('member_emails')
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      if (documentSnapshot.exists) {
        emailEndings = documentSnapshot.data()!['member_emails'];
        print('endings exist');
        print(checkIfMember(userEmail));

        return print(emailEndings);
      } else {
        return print('does not exist');
      }
    });
  }
}
