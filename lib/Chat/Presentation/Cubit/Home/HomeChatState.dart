import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Chat/Domain/Models/ChatRoom.dart';

class HomeChatState{}

class initialChat extends HomeChatState{}

class loading extends HomeChatState{}

class getUserSuccess extends HomeChatState{
  final List<UserApp>? listUser;
  final List<ChatRoom>? listChat;
  getUserSuccess({required this.listUser, required this.listChat});

  getUserSuccess copyWith({List<UserApp>? listUser,List<ChatRoom>? listChat}){
    return getUserSuccess(
      listUser: listUser ?? this.listUser,
      listChat: listChat ?? this.listChat
    );
  }

}
class onError extends HomeChatState{
  String? message;
  onError(this.message);
}