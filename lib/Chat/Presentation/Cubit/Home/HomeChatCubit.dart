import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Chat/Domain/Models/ChatRoom.dart';
import 'package:chat_app/Chat/Domain/Repo/ChatRepo.dart';
import 'package:chat_app/Chat/Presentation/Cubit/Home/HomeChatState.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeChatCubit extends Cubit<HomeChatState>{
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  HomeChatCubit({required this.chatRepo}) :super(initialChat());

  final ChatRepo chatRepo;

  List<UserApp>? _listUser;


  List<UserApp>? get listUser => _listUser;

  //getUser
  Future<List<UserApp?>?> getListUser() async{
    emit(loading());
    try{
      Stream<QuerySnapshot<Map<String, dynamic>>> Stream_snapshots = chatRepo.getAllUser();
      Stream_snapshots.listen(
          (QuerySnapshot<Map<String, dynamic>> snapshots){
            List<UserApp>? parseList = snapshots.docs.map((e)=> UserApp.fromJson(e.data())).toList();
            _listUser = parseList;
            if(state is getUserSuccess){
              final currentState = state as getUserSuccess;
              emit(currentState.copyWith(listUser: parseList));
            }else{
              //fisrt initial
              emit(getUserSuccess(listUser: parseList, listChat: []));

            }
          },
        onError: (error){
            emit(onError(error.toString()));
        }
      );
    }catch (e){
      emit(onError(e.toString()));
    }
    return null;
  }

  //check chat room
  Future<bool> checkChat(String id2) async{
    final check = await chatRepo.checkChatRoom(id2);
    if(check != null){
      return check;
    }
    return false;
  }

  //create chat room
  Future<ChatRoom> createChat(String ID2)async{
    final chat = await chatRepo.createChatRoom(ID2);
    return chat;
  }
  //get list chat room
  Future<List<ChatRoom>?> getAllChat() async{
    emit(loading());
    try{
      Stream<QuerySnapshot<Map<String,dynamic>>> stream = chatRepo.getAllChat();
      stream.listen(
          (QuerySnapshot<Map<String,dynamic>> snapshots){
            List<ChatRoom>? parseList = snapshots.docs.map((e)=> ChatRoom.fromJson(e.data())).toList();
              if(state is getUserSuccess) {
                final currentState = state as getUserSuccess;
                emit(currentState.copyWith(listChat: parseList));
              }else{
                emit(getUserSuccess(listUser: [], listChat: parseList));
              }
          },
          onError: (error){
            emit(onError(error.toString()));
          }
      );
    }catch(e){
      emit(onError(e.toString()));
    }
    return null;
  }
  //delete chat room
    Future<void> deleteChatRoom(String chatID) async{
      return _firebaseFirestore.collection('Chats').doc(chatID).delete();
    }
}