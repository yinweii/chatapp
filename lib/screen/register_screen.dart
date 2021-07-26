import 'dart:io';
import 'package:chatapp/screen/home_screen.dart';
import 'package:chatapp/screen/login_screen.dart';
import 'package:chatapp/services/validator.dart';
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
  FirebaseStorage storage = FirebaseStorage.instance;
  Validator validator = Validator();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? imageAvata;
  bool _isChecked = true;

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
                  CustomTextField(
                    lable: 'Name',
                    controller: _nameController,
                    preIcon: Icon(
                      Icons.person,
                    ),
                    hintext: 'User name',
                    obstype: false,
                    validator: validator.validateName,
                  ),
                  SizedBox(height: 30),
                  CustomTextField(
                    lable: 'Email',
                    controller: _emailController,
                    preIcon: Icon(
                      Icons.mail,
                    ),
                    hintext: 'Enter your email',
                    obstype: false,
                    validator: validator.validateEmail,
                  ),
                  SizedBox(height: 30),
                  CustomTextField(
                    lable: 'Password',
                    controller: _passwordController,
                    preIcon: Icon(
                      Icons.lock,
                    ),
                    sufIcon: IconButton(
                        onPressed: _onToggePass,
                        icon: Icon(
                          _isChecked ? Icons.visibility_off : Icons.visibility,
                        )),
                    hintext: 'Password',
                    obstype: _isChecked,
                    validator: validator.validatePassword,
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
                      Text('I have an Account?'),
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
                              fontWeight: FontWeight.w500,
                              color: Colors.lightBlue),
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

  //upload user infor To FirebaseStorage
  uploadToStorage() async {
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

// user register
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
