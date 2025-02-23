import 'package:chat_app/Chat/Domain/Repo/ChatRepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Domain/Models/ChatRoom.dart';
import '../Domain/Models/Message.dart';

class ChatData implements ChatRepo{
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    return _firebaseFirestore.collection('UserData')
        .where('id', isNotEqualTo: _firebaseAuth.currentUser!.uid)
        .snapshots();
  }

  @override
  Future<bool?> checkChatRoom( String ID2) async {
    final genID = [_firebaseAuth.currentUser!.uid,ID2];
    genID.sort();
    final String chatID = genID.join('_');
    DocumentReference documents =  _firebaseFirestore.collection('Chats').doc(chatID);
    try{
      DocumentSnapshot snapshot = await documents.get();
      return snapshot.exists;
    }catch(e){
      return null;
    }
  }
  
  @override
  Future<ChatRoom> createChatRoom(String ID2)async {
    final genID = [_firebaseAuth.currentUser!.uid,ID2];
    genID.sort();
    final String chatID = genID.join('_');
    final ChatRoom chat = ChatRoom(
        ID_Room: chatID,
        listMessage: [],
        participant: genID
    );
    await _firebaseFirestore.collection('Chats').doc(chatID).set(chat.toMap());
    return chat;
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllChat() {
    return _firebaseFirestore.collection('Chats').where('participant', arrayContains:_firebaseAuth.currentUser!.uid ).snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessage(String ID2) {
    final genID = [_firebaseAuth.currentUser!.uid,ID2];
    genID.sort();
    final String chatID = genID.join('_');
    final x =  _firebaseFirestore.collection('Chats')
        .where('ID_Room', isEqualTo: chatID)
        .snapshots();
    return x;
  }

  @override
  Future<void> sendMessage(Message mess,String ID2)async {
    try {
      final genID = [_firebaseAuth.currentUser!.uid,ID2];
      genID.sort();
      final String chatID = genID.join('_');
      await _firebaseFirestore.collection('Chats').doc(chatID).update(
        {
          'listMessage': FieldValue.arrayUnion([mess.toMap()])
        }
      );
    } catch (e) {
      throw Exception(e);
    }
  }

}