import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message{
  String senderID;
  String content;
  MessageType type;
  Timestamp sendAt;

  Message({required this.senderID,required this.content,required this.type,required this.sendAt});

  factory Message.fromJson(Map<String, dynamic> json){
    return Message(
      senderID: json['senderID'] as String,
        content: json['content'] as String,
        type: MessageType.values.byName(json['type']),
        sendAt: json['sendAt']
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'senderID': senderID,
      'content':content,
      'type':type.name,
      'sendAt': sendAt
    };
  }
}