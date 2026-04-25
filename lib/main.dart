import 'package:flutter/material.dart';
import 'presentation/screens/signup_screen.dart';

void main() {
  runApp(const TwitterCloneApp());
}

class TwitterCloneApp extends StatelessWidget {
  const TwitterCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twitter Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: SignupScreen(),
    );
  }
}
