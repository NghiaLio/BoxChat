import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message{
  String senderID;
  String content;
  Map? replyingTo;
  MessageType type;
  bool seen;
  bool tail;
  Timestamp sendAt;

  Message({required this.senderID,required this.content,this.replyingTo,required this.type,required this.sendAt, required this.seen, required this.tail});

  factory Message.fromJson(Map<String, dynamic> json){
    return Message(
      senderID: json['senderID'] as String,
        content: json['content'] as String,
        replyingTo: json['replyingTo'] ?? {},
        type: MessageType.values.byName(json['type']),
        sendAt: json['sendAt'],
        seen: json['seen'] ?? false,
        tail: json['tail'] ?? false,
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'senderID': senderID,
      'content':content,
      'replyingTo':replyingTo,
      'type':type.name,
      'seen':seen,
      'tail':tail,
      'sendAt': sendAt
    };
  }
}