import 'package:flutter/material.dart';
import 'package:projeto_gps_1/screens/login_screen.dart';
import 'package:projeto_gps_1/screens/register_screen.dart';
import 'package:projeto_gps_1/screens/home_screen.dart';
import 'package:projeto_gps_1/screens/group_screen.dart';
import 'package:projeto_gps_1/screens/chat_screen.dart';
import 'package:projeto_gps_1/screens/friends_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => LoginScreen(),
  '/register': (context) => RegisterScreen(),
  '/home': (context) => const HomeScreen(),
  '/group': (context) => const GroupScreen(),
  '/chat': (context) => ChatScreen(),
  '/friends': (context) => const FriendsScreen(),
};
