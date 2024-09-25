import 'package:flutter/material.dart';
import 'app_drawer.dart'; // Import für den Drawer

class HomePage extends StatelessWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true, // Titel zentrieren
      ),
      drawer:
          AppDrawer(), // Drawer hinzufügen (wird im nächsten Schritt erstellt)
      body: const Center(
        child: Text(
          'Willkommen zur MannschaftsApp!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
