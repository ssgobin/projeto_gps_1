import 'package:flutter/material.dart';
import 'package:projeto_gps_1/widgets/custom_text_field.dart';
import 'package:projeto_gps_1/widgets/custom_button.dart';
import 'package:projeto_gps_1/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            CustomButton(
              text: 'Login',
              onPressed: () async {
                setState(() {
                  errorMessage = ''; // Limpa a mensagem de erro atual
                });
                String email = emailController.text.trim();
                String password = passwordController.text.trim();

                // Validação de entrada
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

                try {
                  await AuthService.login(email, password);
                  Navigator.pushReplacementNamed(context, '/home');
                } catch (e) {
                  setState(() {
                    errorMessage = 'Falha ao fazer login. Verifique suas credenciais.';
                  });
                }
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Não tem uma conta? Cadastre-se'),
            ),
          ],
        ),
      ),
    );
  }
}
