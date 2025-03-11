import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message{
  String senderID;
  String content;
  MessageType type;
  bool seen;
  Timestamp sendAt;

  Message({required this.senderID,required this.content,required this.type,required this.sendAt, required this.seen});

  factory Message.fromJson(Map<String, dynamic> json){
    return Message(
      senderID: json['senderID'] as String,
        content: json['content'] as String,
        type: MessageType.values.byName(json['type']),
        sendAt: json['sendAt'],
        seen: json['seen'] ?? false
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'senderID': senderID,
      'content':content,
      'type':type.name,
      'seen':seen,
      'sendAt': sendAt
    };
  }
}