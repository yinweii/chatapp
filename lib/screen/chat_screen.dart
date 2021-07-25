import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/widget/chat_widget.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;

  const ChatScreen(
      {Key? key,
      required this.receiverId,
      required this.receiverAvatar,
      required this.receiverName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(receiverAvatar),
            ),
          ),
        ],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          receiverName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Chat(receiverId: receiverId, receiverAvatar: receiverAvatar),
    );
  }
}
