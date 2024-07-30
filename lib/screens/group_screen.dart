import 'package:flutter/material.dart';
import 'package:projeto_gps_1/screens/create_group_screen.dart';
import 'package:projeto_gps_1/screens/join_group_screen.dart';
import 'package:projeto_gps_1/widgets/map_widget.dart';

class GroupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grupos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateGroupScreen()),
                );
              },
              child: Text('Criar Grupo'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50), // Ajusta o tamanho do botão
              ),
            ),
            SizedBox(height: 20), // Espaçamento entre os botões
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JoinGroupScreen()),
                );
              },
              child: Text('Entrar em Grupo'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50), // Ajusta o tamanho do botão
              ),
            ),
            SizedBox(height: 20), // Espaçamento entre os botões
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/grouplist');
              },
              child: const Text('Meus grupos'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50), // Ajusta o tamanho do botão
              ),
            ),
          ],
        ),
      ),
    );
  }
}
