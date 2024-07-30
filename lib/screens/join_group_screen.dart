import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_gps_1/widgets/map_widget.dart'; // Corrija a importação se necessário

class JoinGroupScreen extends StatefulWidget {
  @override
  _JoinGroupScreenState createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _codeController = TextEditingController();

  Future<void> _joinGroup() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(code).get();

    if (groupDoc.exists) {
      final groupData = groupDoc.data();
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;

        // Adiciona o usuário ao grupo
        await FirebaseFirestore.instance.collection('groups').doc(code).update({
          'members': FieldValue.arrayUnion([userId]),
        });

        // Adiciona o grupo à lista de grupos do usuário
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'groups': FieldValue.arrayUnion([code]),
        });

        // Confirmação de sucesso e navegação para a tela do mapa do grupo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Você entrou no grupo com sucesso!')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => MapWidget(groupId: code), // Passe o ID do grupo para o MapWidget
          ),
        );
      }
    } else {
      // Grupo não encontrado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código do grupo inválido!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entrar em Grupo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _codeController,
              decoration: InputDecoration(labelText: 'Código do Grupo'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinGroup,
              child: Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
