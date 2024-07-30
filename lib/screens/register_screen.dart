import 'package:flutter/material.dart';
import 'package:projeto_gps_1/widgets/custom_text_field.dart';
import 'package:projeto_gps_1/widgets/custom_button.dart';
import 'package:projeto_gps_1/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: usernameController,
              label: 'Nome de usuário',
            ),
            CustomTextField(
              controller: emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            CustomTextField(
              controller: passwordController,
              label: 'Senha',
              obscureText: true,
            ),
            CustomTextField(
              controller: phoneController,
              label: 'Telefone',
              keyboardType: TextInputType.phone,
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            CustomButton(
              text: 'Cadastrar',
              onPressed: () async {
                setState(() {
                  errorMessage = ''; // Limpa a mensagem de erro atual
                });
                String username = usernameController.text.trim();
                String email = emailController.text.trim();
                String password = passwordController.text.trim();
                String phone = phoneController.text.trim();

                // Validação de entrada
                if (username.isEmpty) {
                  setState(() {
                    errorMessage = 'Por favor, insira seu nome de usuário.';
                  });
                  return;
                }
                if (email.isEmpty || !email.contains('@')) {
                  setState(() {
                    errorMessage = 'Por favor, insira um email válido.';
                  });
                  return;
                }
                if (password.length < 6) {
                  setState(() {
                    errorMessage = 'A senha deve ter pelo menos 6 caracteres.';
                  });
                  return;
                }
                if (phone.isEmpty) {
                  setState(() {
                    errorMessage = 'Por favor, insira seu telefone.';
                  });
                  return;
                }

                try {
                  await AuthService.register(username, email, password, phone);
                  Navigator.pushReplacementNamed(context, '/home');
                } catch (e) {
                  setState(() {
                    errorMessage = 'Falha ao criar a conta. Verifique os dados inseridos.';
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
