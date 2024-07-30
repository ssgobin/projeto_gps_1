import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addFriend() async {
    final friendEmail = _emailController.text.trim();
    if (friendEmail.isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Verificar se o email do amigo existe no Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: friendEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          final friends = List<String>.from(userData!['friends'] ?? []);

          if (!friends.contains(friendEmail)) {
            friends.add(friendEmail);

            await _firestore.collection('users').doc(currentUser.uid).update({
              'friends': friends,
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Amigo adicionado com sucesso!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Este amigo já está na sua lista!')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email do amigo não encontrado no Firebase!')),
        );
      }
    }

    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amigos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email do Amigo',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addFriend,
                ),
              ],
            ),
          ),
          Expanded(
            child: currentUser == null
                ? Center(child: Text('Usuário não autenticado'))
                : StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('users').doc(currentUser.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final userData = snapshot.data?.data() as Map<String, dynamic>?;
                final friends = List<String>.from(userData?['friends'] ?? []);

                return ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(friends[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
