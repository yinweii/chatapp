import 'package:chatapp/screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> signInUser(
      BuildContext context, String email, String pass) async {
    User? user;
    Fluttertoast.showToast(msg: 'Login...');
    await _auth
        .signInWithEmailAndPassword(email: email, password: pass)
        .then((authUser) {
      user = authUser.user;
    }).catchError((err) {
      Fluttertoast.showToast(msg: '${err.toString()}');
    });
    //save data
    if (user != null) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString('id', user!.uid);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            currentUserId: user!.uid,
          ),
        ),
      );
    }
  }
}
