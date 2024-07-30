import 'package:cloud_firestore/cloud_firestore.dart';

class GroupService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> createGroup(String groupName, String leaderId) async {
    await _firestore.collection('groups').add({
      'name': groupName,
      'leader': leaderId,
      'createdAt': Timestamp.now(),
    });
  }

  static Stream<QuerySnapshot> getGroups() {
    return _firestore.collection('groups').snapshots();
  }
}
