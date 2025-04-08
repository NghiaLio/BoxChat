import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';

import '../Chat/Domain/Models/Message.dart';
import 'Avatar.dart';

class itemMessImage extends StatelessWidget {
  final Message message;
  final bool isSender;
  final UserApp? currentUser;
  final UserApp? receiveUser;
  final Function(String, UserApp, MessageType) displayImage;
  const itemMessImage(
      {super.key,
      required this.message,
      required this.isSender,
      this.currentUser,
      this.receiveUser,
      required this.displayImage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: BubbleNormalImage(
        seen: message.seen,
        tail: message.tail,
        id: message.content,
        onTap: () => displayImage(message.content,
            isSender ? currentUser! : receiveUser!, message.type),
        onLongPress: null,
        image: CacheImage(
            imageUrl: message.content,
            widthPlachoder: 0.6,
            heightPlachoder: 0.4),
        isSender: isSender,
      ),
    );
  }
}
