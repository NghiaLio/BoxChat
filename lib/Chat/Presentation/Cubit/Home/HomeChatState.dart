import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Chat/Domain/Models/ChatRoom.dart';

class HomeChatState{}

class initialChat extends HomeChatState{}

class loading extends HomeChatState{}

class getUserSuccess extends HomeChatState{
  final List<UserApp>? listFriends;
  final List<UserApp>? listUsers;
  final List<ChatRoom>? listChat;
  getUserSuccess({required this.listFriends, required this.listChat, required this.listUsers});

  getUserSuccess copyWith({List<UserApp>? listFriends,List<ChatRoom>? listChat, List<UserApp>? listUsers}){
    return getUserSuccess(
      listFriends: listFriends ?? this.listFriends,
      listChat: listChat ?? this.listChat,
      listUsers: listUsers ?? this.listUsers
    );
  }

}
class onError extends HomeChatState{
  String? message;
  onError(this.message);
}