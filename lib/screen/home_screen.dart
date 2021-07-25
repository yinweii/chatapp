import 'package:chatapp/model/user.dart';
import 'package:chatapp/screen/login_screen.dart';
import 'package:chatapp/widget/chatuseritem_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  const HomeScreen({required this.currentUserId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CollectionReference userList = FirebaseFirestore.instance.collection('users');
  List userInServer = [];

  //get data
  Future getUserList() async {
    List itemList = [];
    await userList.get().then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        if (widget.currentUserId != element.id) {
          itemList.add(element.data());
        }
      });
    });
    return itemList;
  }

  featchUSerData() async {
    dynamic resuld = await getUserList();

    setState(() {
      userInServer = resuld;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    featchUSerData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildHomePageHeader(),
      body: displayUser(),
    );
  }

  displayUser() {
    return ListView.builder(
      itemCount: userInServer.length,
      itemBuilder: (context, index) {
        return ChatUserItem(
            receiverId: userInServer[index]['uid'],
            name: userInServer[index]['name'],
            image: userInServer[index]['image']);
      },
    );
  }

//build home page header
  buildHomePageHeader() {
    return AppBar(
      actions: [
        IconButton(
            icon: Icon(
              Icons.logout,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () {
              signOut();
              // Navigator.of(context).pushReplacement(
              //     MaterialPageRoute(builder: (context) => LogInScreen()));
            }),
      ],
      backgroundColor: Colors.lightBlue,
      title: Container(
        margin: EdgeInsets.only(bottom: 4),
        child: TextFormField(
          style: TextStyle(fontSize: 20, color: Colors.white),

          decoration: InputDecoration(
            hintText: 'Search',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            filled: true,
            prefixIcon: Icon(
              Icons.person_pin,
              color: Colors.white,
              size: 30,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {},
            ),
          ),
          //onFieldSubmitted: ,
        ),
      ),
    );
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut().then((_) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LogInScreen()));
    });
  }
}
