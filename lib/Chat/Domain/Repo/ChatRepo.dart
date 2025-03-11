import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Chat/Domain/Models/ChatRoom.dart';
import 'package:chat_app/Chat/Domain/Models/Message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ChatRepo{
  Future<UserApp> getUserbyID(String ID);
  Stream<QuerySnapshot<Map<String,dynamic>>> getAllFriend();
  Future<bool?> checkChatRoom(String ID2);
  Future<ChatRoom> createChatRoom(String ID2);
  Stream<QuerySnapshot<Map<String,dynamic>>> getAllChat();
  Stream<QuerySnapshot<Map<String,dynamic>>> getMessage(String ID2);
  Future<void> sendMessage(Message mess,String ID2);
  Future<void> seenMessage(String ID2);
}