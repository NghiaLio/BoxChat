import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Chat/Domain/Models/ChatRoom.dart';
import 'package:chat_app/Chat/Domain/Repo/ChatRepo.dart';
import 'package:chat_app/Chat/Presentation/Cubit/ChatRoomBloc/ChatRoomState.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Chatroomcubit extends Cubit<Chatroomstate> {
  Chatroomcubit({required this.chatRepo}) : super(initialChat());

  final ChatRepo chatRepo;

  List<UserApp>? _listUsers;

  List<UserApp>? get listUsers => _listUsers;

  

  //check chat room
  Future<bool> checkChat(String id2) async {
    final check = await chatRepo.checkChatRoom(id2);
    if (check != null) {
      return check;
    }
    return false;
  }

  //create chat room
  Future<ChatRoom> createChat(String ID2) async {
    final chat = await chatRepo.createChatRoom(ID2);
    return chat;
  }

  //get list chat room
  Future<List<ChatRoom>?> getAllChat() async {
    emit(loading());
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> stream =
          chatRepo.getAllChat();
      stream.listen((QuerySnapshot<Map<String, dynamic>> snapshots) {
        List<ChatRoom>? parseList =
            snapshots.docs.map((e) => ChatRoom.fromJson(e.data())).toList();
        emit(getChatSuccess(parseList));
      }, onError: (error) {
        emit(onError(error.toString()));
      });
    } catch (e) {
      emit(onError(e.toString()));
    }
    return null;
  }

  //delete chat room
  Future<void> deleteChatRoom(String chatID) async {
    await chatRepo.deleteChatRoom(chatID);
  }

  //allowNotify
  Future<void> allowNotify(String newToken) async {
    await chatRepo.allowNotify(newToken);
  }

  //refuseNotify
  Future<void> refuseNotify(String token) async {
    await chatRepo.refuseNotify(token);
  }
}
