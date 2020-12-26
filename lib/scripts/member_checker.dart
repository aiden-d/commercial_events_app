import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MemberChecker {
  final firestore = Firestore.instance;
  final userEmail = FirebaseAuth.instance.currentUser.email;
  static bool isMember = false;
  static List<String> emailEndings = [];
//TODO create update endings fucntion
  void main() {
    checkIfMember('aidendawes@gmail.com');
  }

  bool checkIfMember(String email) {
    if (emailEndings.length == 0) {
      print('emails ending null');
      return false;
    }
    for (String e in emailEndings) {
      int start = email.length - e.length;
      int end = start + e.length;
      String newEnding = email.substring(start, end);
      print(newEnding);
      if (newEnding == e) {
        isMember = true;
      }
    }
    return false;
  }

  Future<void> updateEndings() async {
    FirebaseFirestore.instance
        .collection('Admin')
        .doc('member_emails')
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        emailEndings = documentSnapshot.data('member_emails');
      }
    });
  }
}
