import 'package:chat_app/Chat/Domain/Models/Message.dart';

class ChatRoom{
  String ID_Room;
  List<Message> listMessage;
  List<String> participant;

  ChatRoom({required this.ID_Room, required this.listMessage, required this.participant});

  factory ChatRoom.fromJson(Map<String,dynamic> json){
    return ChatRoom(
        ID_Room: json['ID_Room'],
        listMessage: (json['listMessage'] as List<dynamic>).map(
            (e)=> Message.fromJson(e)
        ).toList(),
        participant: List<String>.from(json['participant'])
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'ID_Room': ID_Room,
      'listMessage':listMessage,
      'participant': participant
    };
  }
}