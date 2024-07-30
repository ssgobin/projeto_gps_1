import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_gps_1/screens/login_screen.dart';
import 'package:projeto_gps_1/screens/register_screen.dart';
import 'package:projeto_gps_1/screens/home_screen.dart';
import 'package:projeto_gps_1/screens/group_screen.dart';
import 'package:projeto_gps_1/screens/friends_screen.dart';
import 'package:projeto_gps_1/screens/create_group_screen.dart';
import 'package:projeto_gps_1/screens/groups_list_screen.dart';
import 'package:projeto_gps_1/widgets/map_widget.dart';
import 'package:projeto_gps_1/screens/chat_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amigos de Viagem',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/group': (context) => GroupScreen(),
        '/friends': (context) => FriendsScreen(),
        '/create_group': (context) => CreateGroupScreen(),
        '/grouplist': (context) => GroupsListScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
