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
  TextEditingController searchTextEditingController = TextEditingController();

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

// list user
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
      leading: Center(
        child: Text(
          'CHAT',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 2,
              fontFamily: 'Anton'),
        ),
      ),
      actions: [
        IconButton(
            icon: Icon(
              Icons.logout,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () {
              signOut();
            }),
      ],
    );
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut().then((_) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LogInScreen()));
    });
  }
}
