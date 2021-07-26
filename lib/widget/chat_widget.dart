import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/widget/fullimage_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
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
      chatId = '$id-${widget.receiverId}';
    } else {
      chatId = '${widget.receiverId}-$id';
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
              //input text
              createInput(),
            ],
          ),
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
                onPressed: getImage,
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
                onPressed: takeImageFromCamera,
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

//mesage left
  bool isLastMsgLeft(int index) {
    if ((index > 0 && listMessage != null) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  //message right
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
              //image
              : document['type'] == 1
                  ? Container(
                      margin: EdgeInsets.only(
                          bottom: isLastMsgRight(index) ? 20 : 10, right: 10),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullImage(
                                url: document['content'],
                              ),
                            ),
                          );
                        },
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              padding: EdgeInsets.all(70),
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.lightBlueAccent,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Image.asset(
                                'images/img_not_av.jpeg',
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            imageUrl: document['content'],
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
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
                        ? Container(
                            margin: EdgeInsets.only(
                                bottom: isLastMsgRight(index) ? 20 : 10,
                                right: 10),
                            child: FlatButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullImage(
                                      url: document['content'],
                                    ),
                                  ),
                                );
                              },
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    padding: EdgeInsets.all(50),
                                    height: 200,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.lightBlueAccent,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Image.asset(
                                      'images/img_not_av.jpeg',
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  imageUrl: document['content'],
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                            ),
                          )
                        : Container(),
              ],
            ),
            //msg time
            isLastMsgLeft(index)
                ? Container(
                    margin: EdgeInsets.only(top: 1, bottom: 5),
                    child: Text(
                      DateFormat('dd MMMM,yyyy -hh:mm:aa').format(
                        DateTime.fromMillisecondsSinceEpoch(
                          int.parse(
                            document['timestamp'],
                          ),
                        ),
                      ),
                      style: TextStyle(color: Colors.grey, fontSize: 10),
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

  Future getImage() async {
    PickedFile? photo =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      imageFile = File(photo!.path);
    });
    if (imageFile != null) {
      isLoading = false;
    }
    upLoadImageFile();
  }

  Future takeImageFromCamera() async {
    PickedFile? photo = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    setState(() {
      imageFile = File(photo!.path);
    });
    if (imageFile != null) {
      isLoading = false;
    }
    upLoadImageFile();
  }

  Future upLoadImageFile() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    Reference ref = storage.ref().child('ChatImage').child(fileName);
    UploadTask uploadTask = ref.putFile(imageFile!);
    uploadTask.then((TaskSnapshot taskSnapshot) {
      taskSnapshot.ref.getDownloadURL().then((value) {
        setState(() {
          imageUrl = value;
          isLoading = false;
          onSendMessage(imageUrl!, 1);
        });
      });
    }).catchError((error) {
      Fluttertoast.showToast(msg: '${error.toString()}');
    });
  }
}
