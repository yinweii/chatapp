import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Chat extends StatefulWidget {
  final String receiverId;
  final String receiverAvatar;
  const Chat({Key? key, required this.receiverId, required this.receiverAvatar})
      : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final ScrollController listScrollController = ScrollController();
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool? isLoading;
  File? imageFile;
  String? imageUrl;
  String? chatId;
  String? id;
  var listMessage;
  SharedPreferences? preferences;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    chatId = '';
    readLocal();
  }

  readLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences!.getString('id');
    if (id.hashCode <= widget.receiverId.hashCode) {
      chatId = '$id-$widget.receiverId';
    } else {
      chatId = '$widget.receiverId-$id';
    }
    // get
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'chattingWith': widget.receiverId});

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('IDDD: $id');
    return WillPopScope(
      onWillPop: onBackpress,
      child: Stack(
        children: [
          Column(
            children: [
              //List of message
              createListMessage(),
              //show sticker
              //(isDisPlaySticker ? createSticker() : Container()),
              //input text
              createInput(),
            ],
          ),
          //createloading(),
        ],
      ),
    );
  }

  Future<bool> onBackpress() async {
    return Future.value(false);
  }

  //create Input Message
  createInput() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        color: Colors.white,
      ),
      child: Row(
        children: [
          //image button
          Material(
            child: Container(
              child: IconButton(
                icon: Icon(
                  Icons.image,
                  color: Colors.lightBlueAccent,
                ),
                onPressed: () {},
              ),
              color: Colors.white,
            ),
          ),
          //Emoji button
          Material(
            child: Container(
              child: IconButton(
                icon: Icon(
                  Icons.add_a_photo,
                  color: Colors.lightBlueAccent,
                ),
                onPressed: () {},
              ),
              color: Colors.white,
            ),
          ),
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: Colors.black, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration(
                  hintText: 'Write here...',
                  hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          Material(
            child: Container(
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.lightBlueAccent,
                ),
                onPressed: () => onSendMessage(textEditingController.text, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //list message
  createListMessage() {
    return Flexible(
      child: chatId == ''
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(chatId)
                  .collection(chatId!)
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation(Colors.lightBlueAccent),
                    ),
                  );
                } else {
                  listMessage = snapshot.data!.docs;
                  return ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemBuilder: (context, index) =>
                        createItem(index, snapshot.data!.docs[index]),
                    itemCount: snapshot.data!.docs.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

//--------->isLastMsgLeft<-------------&& listMessage[index - 1]['idFrom' == id]
  bool isLastMsgLeft(int index) {
    if ((index > 0 && listMessage != null) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  //---->isLastMsgRight<-----------------&& listMessage[index - 1]['idFrom' == id]
  bool isLastMsgRight(int index) {
    if ((index > 0 && listMessage != null) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget createItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == id) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          document['type'] == 0
              //text
              ? Container(
                  padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  margin: EdgeInsets.only(
                      bottom: isLastMsgRight(index) ? 20 : 10, right: 10),
                  child: Text(
                    document['content'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                )
              : Container(),
        ],
      );
    } else {
      return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLastMsgLeft(index)
                    ? Material(
                        //display receiver profile image
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            padding: EdgeInsets.all(10),
                            height: 35,
                            width: 35,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.lightBlueAccent,
                              ),
                            ),
                          ),
                          imageUrl: widget.receiverAvatar,
                          height: 35,
                          width: 35,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(
                        width: 35,
                      ),
                //display message
                document['type'] == 0
                    ? Container(
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(7),
                        ),
                        margin: EdgeInsets.only(left: 10),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                          child: Text(
                            document['content'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      )
                    : document['type'] == 1
                        ? Container()
                        : Container(),
              ],
            ),
            //msg time
            isLastMsgLeft(index)
                ? Container(
                    margin: EdgeInsets.only(left: 50, top: 10, bottom: 5),
                    child: Text(
                      DateFormat('dd MMMM,yyyy -hh:mm:aa').format(
                        DateTime.fromMillisecondsSinceEpoch(
                          int.parse(
                            document['timestamp'],
                          ),
                        ),
                      ),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  )
                : Container(),
          ],
        ),
      );
    }
  }

  // send message
  void onSendMessage(String contentMsg, int type) {
    //type = 0 : text Msg
    //type = 1 : image
    if (contentMsg != '') {
      textEditingController.clear();
      var docRef = FirebaseFirestore.instance
          .collection('messages')
          .doc(chatId)
          .collection(chatId!)
          .doc(DateTime.now().microsecondsSinceEpoch.toString());
      FirebaseFirestore.instance.runTransaction((transaction) async {
        // ignore: await_only_futures
        await transaction.set(docRef, {
          'idFrom': id,
          'idTo': widget.receiverId,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': contentMsg,
          'type': type,
        });
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: "Can't not send message");
    }
  }
}
