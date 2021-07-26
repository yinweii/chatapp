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
          icon: Icon(Icons.keyboard_backspace),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.phone),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.video_call),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.error),
          ),
        ],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(receiverAvatar),
            ),
            SizedBox(width: 10),
            Text(
              receiverName,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Chat(receiverId: receiverId, receiverAvatar: receiverAvatar),
    );
  }
}
