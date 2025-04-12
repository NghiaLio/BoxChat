
// ignore_for_file: camel_case_types

import 'package:chat_app/Chat/Domain/Models/ChatRoom.dart';

class Chatroomstate {}

class initialChat extends Chatroomstate {}

class loading extends Chatroomstate {}

class getChatSuccess extends Chatroomstate {
  final List<ChatRoom>? listChat;
  getChatSuccess(this.listChat);
}

class onError extends Chatroomstate {
  String? message;
  onError(this.message);
}
