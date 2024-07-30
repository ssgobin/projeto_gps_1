import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bem-vindo ao Amigos de Viagem!'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/group');
              },
              child: const Text('Iniciar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut(); // Faz o logout
                Navigator.pushReplacementNamed(context, '/login'); // Navega para a tela de login
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
