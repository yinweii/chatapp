import 'package:chatapp/screen/home_screen.dart';
import 'package:chatapp/screen/register_screen.dart';
import 'package:chatapp/utils/global.dart';
import 'package:chatapp/widget/custombuttom_widget.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  GlobalKey<FormState> _formLogIn = GlobalKey<FormState>();
  bool _isChecked = true;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formLogIn,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.teal,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login',
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _email,
                  obscureText: false,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    hintText: 'email',
                    hintStyle: kHintTextStyle,
                    prefixIcon: Icon(
                      Icons.mail,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _password,
                  obscureText: _isChecked,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    hintText: 'Password',
                    hintStyle: kHintTextStyle,
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.white,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _onToggePass,
                      icon: Icon(
                        _isChecked ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 35),
                CustomButton(
                  text: 'LogIn',
                  onPress: () {
                    if (_formLogIn.currentState!.validate()) {
                      signInUser();
                    }
                  },
                ),
                CustomButton(
                  text: 'Register',
                  onPress: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => RegisterScreen()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signInUser() async {
    User? user;
    Fluttertoast.showToast(msg: 'Login...');
    await _auth
        .signInWithEmailAndPassword(
            email: _email.text.trim(), password: _password.text.trim())
        .then((authUser) {
      user = authUser.user;
    }).catchError((err) {
      Fluttertoast.showToast(msg: '${err.toString()}');
    });
    //save data
    if (user != null) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString('id', user!.uid);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomeScreen(
                currentUserId: user!.uid,
              )));
    }
  }

  void _onToggePass() {
    setState(() {
      _isChecked = !_isChecked;
    });
  }
}
