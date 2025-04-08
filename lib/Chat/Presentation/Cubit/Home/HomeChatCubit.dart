import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Chat/Domain/Models/ChatRoom.dart';
import 'package:chat_app/Chat/Domain/Repo/ChatRepo.dart';
import 'package:chat_app/Chat/Presentation/Cubit/Home/HomeChatState.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeChatCubit extends Cubit<HomeChatState> {
 

  HomeChatCubit({required this.chatRepo}) : super(initialChat());

  final ChatRepo chatRepo;

  List<UserApp>? _listFriends;
  List<UserApp>? _listUsers;

  List<UserApp>? get listFriends => _listFriends;
  List<UserApp>? get listUsers => _listUsers;

  


  //getAllUser
  Future<List<UserApp>?> getAllUsers() async{
    emit(loading());
    try {
      final List<UserApp>? listParse = await chatRepo.getAllUser();
      _listUsers = listParse;
      emit(getUserSuccess(listFriends: [], listChat: [], listUsers: listParse));
    } catch (e) {
      emit(onError(e.toString()));
    }
    return null;
  }

  //getAllFriends
  Future<List<UserApp?>?> getListFriends() async {
    emit(loading());
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> Stream_snapshots =
          chatRepo.getAllFriend();
      Stream_snapshots.listen(
          (QuerySnapshot<Map<String, dynamic>> snapshots) async {
        UserApp user = snapshots.docs
            .map((e) => UserApp.fromJson(e.data()))
            .toList()
            .first;
        final List<String>? listFriends = user.friends!;
        if (listFriends!.isNotEmpty) {
          List<UserApp>? parseList =
              await Future.wait(listFriends.map((id) async {
            return await chatRepo.getUserbyID(id);
          }));
          _listFriends = parseList;
          if (state is getUserSuccess) {
            final currentState = state as getUserSuccess;
            emit(currentState.copyWith(listFriends: parseList));
          } else {
            //fisrt initial
            emit(getUserSuccess(listFriends: parseList, listChat: [], listUsers: []));
          }
        }
      }, onError: (error) {
        emit(onError(error.toString()));
      });
    } catch (e) {
      emit(onError(e.toString()));
    }
    return null;
  }

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
        if (state is getUserSuccess) {
          final currentState = state as getUserSuccess;
          emit(currentState.copyWith(listChat: parseList));
        } else {
          emit(getUserSuccess(listFriends: [], listChat: parseList, listUsers: []));
        }
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
  Future<void> allowNotify(String newToken) async{
    await chatRepo.allowNotify(newToken);
  }
  //refuseNotify
  Future<void> refuseNotify(String token) async{
    await chatRepo.refuseNotify(token);
  }
}
