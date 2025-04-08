import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Chat/Domain/Models/ChatRoom.dart';
import 'package:chat_app/Chat/Domain/Models/Message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ChatRepo{
  Future<UserApp> getUserbyID(String ID);
  Future<List<UserApp>?> getAllUser();
  Stream<QuerySnapshot<Map<String,dynamic>>> getAllFriend();
  // Stream<QuerySnapshot<Map<String,dynamic>>> getAllUser();
  Future<bool?> checkChatRoom(String ID2);
  Future<ChatRoom> createChatRoom(String ID2);
  Future<void> deleteChatRoom(String chatID);
  Stream<QuerySnapshot<Map<String,dynamic>>> getAllChat();
  Stream<QuerySnapshot<Map<String,dynamic>>> getMessage(String ID2);
  Future<void> sendMessage(UserApp currentUser,UserApp receiveUser,Message mess);
  Future<void> sendPushNotification(UserApp currentUser,UserApp receiveUser, String message);
  Future<void> allowNotify(String newToken);
  Future<void> refuseNotify(String Token);
  Future<void> seenMessage(String ID2);
  Future<void> unTailMessage(String ID2); // set un tail message => set tail = false cho cac tin nhan truoc do
  Future<void> deleteMessage(String ID2, Timestamp time);
}