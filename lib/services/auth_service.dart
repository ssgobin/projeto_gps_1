import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> register(String username, String email, String password, String phone) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    User? user = userCredential.user;

    if (user != null) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      await _firestore.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
        'phone': phone,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'createdAt': Timestamp.now(),
      });
    }
  }

  static Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);

    User? user = _auth.currentUser;
    if (user != null) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      await _firestore.collection('users').doc(user.uid).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}
