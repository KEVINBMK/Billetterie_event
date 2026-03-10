import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import './public/test_auth_screen.dart';
import './public/test_event_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Billetterie'),
        actions: [
          if (auth.user != null)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => auth.signOut(),
            )
          else
            IconButton(
              icon: Icon(Icons.login),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TestAuthScreen()),
                );
              },
            ),
        ],
      ),
      drawer: auth.user != null ? _buildDrawer(context) : null,
      body: TestEventScreen(),
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
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Événements'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}