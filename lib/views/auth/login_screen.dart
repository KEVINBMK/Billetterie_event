import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart'; // à créer

class LoginScreen extends StatelessWidget {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController pwdCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: pwdCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Mot de passe')),
            ElevatedButton(
              onPressed: () async {
                await auth.signInWithEmail(emailCtrl.text, pwdCtrl.text);
              },
              child: Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}