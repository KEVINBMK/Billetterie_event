// lib/views/main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import './public/test_auth_screen.dart';
import './public/test_event_screen.dart';
import './public/test_reservation_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Billetterie - Test'),
        actions: [
          if (auth.user != null)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => auth.signOut(),
            ),
        ],
      ),
      drawer: auth.user != null ? _buildDrawer(context) : null,
      body: auth.user == null
          ? TestAuthScreen()
          : _buildTestMenu(context, auth),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu de test',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Événements'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TestEventScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestMenu(BuildContext context, AuthController auth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Connecté en tant que ${auth.user?.email} (${auth.role})'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TestEventScreen()),
              );
            },
            child: Text('Tester les événements'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Redirige vers la liste des événements pour en choisir un
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TestEventScreen()),
              );
            },
            child: Text('Tester les réservations'),
          ),
        ],
      ),
    );
  }
}