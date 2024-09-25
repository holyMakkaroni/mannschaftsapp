import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Entferne das `const`-Schlüsselwort, wenn du keinen Key verwendest
  // const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mannschafts App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Optional, je nach Bedarf
      ),
      home: HomePage(title: 'Mannschafts App'),
    );
  }
}
