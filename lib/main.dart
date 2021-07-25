import 'package:chatapp/screen/home_screen.dart';
import 'package:chatapp/screen/login_screen.dart';
import 'package:chatapp/screen/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.teal),
      debugShowCheckedModeBanner: false,
      home: LogInScreen(),
    );
  }
}
