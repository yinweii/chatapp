import 'package:chatapp/screen/register_screen.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/services/validator.dart';
import 'package:chatapp/widget/custombuttom_widget.dart';
import 'package:chatapp/widget/customtextfield_widget.dart';
import 'package:flutter/material.dart';

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

  Validator validator = Validator();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formLogIn,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'AppChat',
                    style: TextStyle(
                      fontSize: 50,
                      fontFamily: 'Anton',
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  CustomTextField(
                    lable: 'Email',
                    preIcon: Icon(Icons.email),
                    hintext: 'Enter your email...',
                    obstype: false,
                    controller: _email,
                    validator: validator.validateEmail,
                  ),
                  SizedBox(height: 30),
                  CustomTextField(
                    lable: 'PassWord',
                    preIcon: Icon(Icons.lock),
                    hintext: 'Password',
                    obstype: _isChecked,
                    controller: _password,
                    validator: validator.validatePassword,
                    sufIcon: IconButton(
                      onPressed: _onToggePass,
                      icon: Icon(
                        _isChecked ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  SizedBox(height: 35),
                  CustomButton(
                    text: 'LogIn',
                    onPress: () async {
                      if (_formLogIn.currentState!.validate()) {
                        AuthService authService = AuthService();
                        authService.signInUser(
                            context, _email.text.trim(), _password.text.trim());
                        // signInUser();
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
      ),
    );
  }

  // Future<void> signInUser() async {
  //   User? user;
  //   Fluttertoast.showToast(msg: 'Login...');
  //   await _auth
  //       .signInWithEmailAndPassword(
  //           email: _email.text.trim(), password: _password.text.trim())
  //       .then((authUser) {
  //     user = authUser.user;
  //   }).catchError((err) {
  //     Fluttertoast.showToast(msg: '${err.toString()}');
  //   });
  //   //save data
  //   if (user != null) {
  //     SharedPreferences preferences = await SharedPreferences.getInstance();
  //     await preferences.setString('id', user!.uid);
  //     Navigator.of(context).pushReplacement(MaterialPageRoute(
  //         builder: (context) => HomeScreen(
  //               currentUserId: user!.uid,
  //             )));
  //   }
  // }

  void _onToggePass() {
    setState(() {
      _isChecked = !_isChecked;
    });
  }
}
