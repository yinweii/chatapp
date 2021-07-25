import 'dart:io';

import 'package:chatapp/screen/home_screen.dart';
import 'package:chatapp/screen/login_screen.dart';
import 'package:chatapp/utils/global.dart';
import 'package:chatapp/widget/custombuttom_widget.dart';
import 'package:chatapp/widget/customtextfield_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String userImageUrl = '';
  FirebaseAuth _auth = FirebaseAuth.instance;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? imageAvata;
  bool _isChecked = true;
  //validate emmail
  String? validateEmail(inputEmail) {
    if (inputEmail.isEmpty) return 'Email is not emty';
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(inputEmail)) return 'Invalid Email address format';
    return null;
  }

  //validate pass
  String? validatePassword(password) {
    if (password.isEmpty) return 'Password is not empty';
    if (password.length <= 6) return 'Password is required';
    return null;
  }

//get image form gallery
  Future getImage() async {
    // ignore: unnecessary_cast
    PickedFile? photo =
        await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      imageAvata = File(photo!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      buildAvata(),
                      Positioned(
                        right: 1,
                        top: 2,
                        child: IconButton(
                          onPressed: getImage,
                          icon: Icon(
                            Icons.add_a_photo,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  /*CustomTextField(
                          lable: 'Name',
                          preIcon: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          hintext: 'User name',
                          obstype: false,
                          validator: () {},
                        ),
                        CustomTextField(
                          lable: 'Email',
                          preIcon: Icon(
                            Icons.mail,
                            color: Colors.white,
                          ),
                          hintext: 'Enter your email',
                          obstype: false,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'email not empty';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          lable: 'Password',
                          preIcon: Icon(
                            Icons.lock,
                            color: Colors.white,
                          ),
                          sufIcon: IconButton(
                              onPressed: _onToggePass,
                              icon: Icon(
                                _isChecked ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white,
                              )),
                          hintext: 'Password',
                          obstype: _isChecked,
                          validator: () {},
                        ), */
                  TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Name is not empty';
                      }
                      return null;
                    },
                    obscureText: false,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 1)),
                      hintText: 'Name',
                      hintStyle: kHintTextStyle,
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    validator: validateEmail,
                    controller: _emailController,
                    obscureText: false,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 1)),
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
                    validator: validatePassword,
                    controller: _passwordController,
                    obscureText: _isChecked,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 1)),
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
                    text: 'Register',
                    onPress: () {
                      if (_formKey.currentState!.validate()) {
                        uploadToStorage();
                        print('save form');
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('I have A Account?'),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => LogInScreen()));
                        },
                        child: Text(
                          'LogIn',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onToggePass() {
    setState(() {
      _isChecked = !_isChecked;
    });
  }

  Widget buildAvata() {
    if (imageAvata == null) {
      return CircleAvatar(
        radius: 80,
        backgroundImage: AssetImage('images/avt.jpg'),
      );
    } else {
      return CircleAvatar(
        radius: 80,
        backgroundImage: FileImage(imageAvata!),
      );
    }
  }

  //register
  uploadToStorage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = storage.ref().child('Image').child(imageFileName);

    UploadTask storageUploadTask = ref.putFile(imageAvata!);

    storageUploadTask.then((TaskSnapshot taskSnapshot) {
      taskSnapshot.ref.getDownloadURL().then((imageUrl) {
        setState(() {
          userImageUrl = imageUrl;
        });
        _registerUser();
      });
    }).catchError((err) {
      Fluttertoast.showToast(msg: '${err.toString()}');
    });
  }

  void _registerUser() async {
    User? firebaseUser;

    await _auth
        .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim())
        .then((authUser) {
      firebaseUser = authUser.user;
    }).catchError((err) {
      Fluttertoast.showToast(msg: '${err.toString()}');
    });
    if (firebaseUser != null) {
      saveUserToFireStore(firebaseUser!).then((_) async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.setString('id', firebaseUser!.uid);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              currentUserId: firebaseUser!.uid,
            ),
          ),
        );
      });
    }
  }

  Future<void> saveUserToFireStore(User fUser) async {
    FirebaseFirestore storage = FirebaseFirestore.instance;
    storage.collection('users').doc(fUser.uid).set({
      'uid': fUser.uid,
      'image': userImageUrl,
      'name': _nameController.text.trim(),
      'email': fUser.email,
      'chattingWith': null,
    });
    //savedata to local
  }
}
