import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_gps_1/widgets/map_widget.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();

  Future<void> _createGroup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final groupId = _generateUniqueCode();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Handle the case where there is no logged-in user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário não autenticado.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('groups').doc(groupId).set({
      'name': name,
      'members': [currentUser.uid], // Inicialmente o líder é o único membro
      'leader': currentUser.uid,     // Define o líder do grupo
    });

    // Adiciona o grupo à lista de grupos do usuário
    await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
      'groups': FieldValue.arrayUnion([groupId]),
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MapWidget(groupId: groupId),
      ),
    );
  }

  String _generateUniqueCode() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Grupo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome do Grupo'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createGroup,
              child: Text('Criar Grupo'),
            ),
          ],
        ),
      ),
    );
  }
}
