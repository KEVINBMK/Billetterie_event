import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';

class TestAuthScreen extends StatelessWidget {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController pwdCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Test Auth')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(auth.user != null ? 'Connecté: ${auth.user!.email} (${auth.role})' : 'Non connecté'),
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: pwdCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Mot de passe')),
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nom (pour inscription)')),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => auth.signInWithEmail(emailCtrl.text, pwdCtrl.text),
                  child: Text('Connexion'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => auth.signUpWithEmail(emailCtrl.text, pwdCtrl.text, nameCtrl.text),
                  child: Text('Inscription'),
                ),
                ElevatedButton(
                  onPressed: auth.signInWithGoogle,
                  child: Text('Google'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: auth.signOut,
              child: Text('Déconnexion'),
            ),
          ],
        ),
      ),
    );
  }
}