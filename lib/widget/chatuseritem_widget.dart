import 'package:chatapp/model/user.dart';
import 'package:chatapp/screen/chat_screen.dart';
import 'package:flutter/material.dart';

class ChatUserItem extends StatelessWidget {
  final String receiverId;

  final String name;
  final String image;

  const ChatUserItem({
    Key? key,
    required this.name,
    required this.image,
    required this.receiverId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                  receiverId: receiverId,
                  receiverAvatar: image,
                  receiverName: name),
            ),
          );
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(image),
              ),
              title: Text(name),
            ),
          ),
        ),
      ),
    );
  }
}
