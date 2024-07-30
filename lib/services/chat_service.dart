import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<QuerySnapshot> getMessages() {
    return _firestore.collection('chats').orderBy('createdAt').snapshots();
  }

  static Future<void> sendMessage(String text) async {
    User? user = _auth.currentUser;

    if (user != null) {
      await _firestore.collection('chats').add({
        'text': text,
        'sender': user.email,
        'createdAt': Timestamp.now(),
      });
    }
  }
}
