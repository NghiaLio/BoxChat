import 'dart:convert';


import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Chat/Domain/Repo/ChatRepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../config/get_service_key.dart';
import '../Domain/Models/ChatRoom.dart';
import '../Domain/Models/Message.dart';
import 'package:http/http.dart' as http;

class ChatData implements ChatRepo {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<UserApp> getUserbyID(String ID) async {
    final UserRef = _firebaseFirestore
        .collection('UserData')
        .withConverter<UserApp>(
          fromFirestore: (snapshot, _) => UserApp.fromJson(snapshot.data()!),
          toFirestore: (user, _) => user.toJson(),
        );
    UserApp user =
        await UserRef.doc(ID).get().then((snapshot) => snapshot.data()!);
    return user;
  }


  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllFriend() {
    return _firebaseFirestore
        .collection('UserData')
        .where('id', isEqualTo: _firebaseAuth.currentUser!.uid)
        .snapshots();
  }

  @override
  Future<bool?> checkChatRoom(String ID2) async {
    final genID = [_firebaseAuth.currentUser!.uid, ID2];
    genID.sort();
    final String chatID = genID.join('_');
    DocumentReference documents =
        _firebaseFirestore.collection('Chats').doc(chatID);
    try {
      DocumentSnapshot snapshot = await documents.get();
      return snapshot.exists;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ChatRoom> createChatRoom(String ID2) async {
    final genID = [_firebaseAuth.currentUser!.uid, ID2];
    genID.sort();
    final String chatID = genID.join('_');
    final ChatRoom chat =
        ChatRoom(ID_Room: chatID, listMessage: [], participant: genID);
    await _firebaseFirestore.collection('Chats').doc(chatID).set(chat.toMap());
    return chat;
  }

  @override
  Future<void> deleteChatRoom(String chatID) async {
    try {
      await _firebaseFirestore.collection('Chats').doc(chatID).delete();
    } catch (e) {
      print((e));
      throw Exception(e);
    }
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllChat() {
    return _firebaseFirestore
        .collection('Chats')
        .where('participant', arrayContains: _firebaseAuth.currentUser!.uid)
        .snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessage(String ID2) {
    final genID = [_firebaseAuth.currentUser!.uid, ID2];
    genID.sort();
    final String chatID = genID.join('_');
    final x = _firebaseFirestore
        .collection('Chats')
        .where('ID_Room', isEqualTo: chatID)
        .snapshots();
    return x;
  }

  @override
  Future<void> sendMessage(
      UserApp currentUser, UserApp receiveUser, Message mess) async {
    try {
      final genID = [_firebaseAuth.currentUser!.uid, receiveUser.id];
      genID.sort();
      final String chatID = genID.join('_');
      await _firebaseFirestore.collection('Chats').doc(chatID).update({
        'listMessage': FieldValue.arrayUnion([mess.toMap()])
      }).then((value) {
        if (mess.type == MessageType.Image) {
          sendPushNotification(currentUser, receiveUser, 'Sent a Image');
        } else if (mess.type == MessageType.Audio) {
          sendPushNotification(currentUser, receiveUser, 'Sent a Audio');
        } else if (mess.type == MessageType.Video) {
          sendPushNotification(currentUser, receiveUser, 'Sent a Video');
        } else {
          sendPushNotification(currentUser, receiveUser, mess.content);
        }
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String> getAccessToken() async {
    GetServerKey getServerKey = GetServerKey();
    String accessToken = await getServerKey.getServiceKeyToken();
    return accessToken;
  }

  @override
  Future<void> sendPushNotification(
      UserApp currentUser, UserApp receiveUser, String message) async {
    try {
      // ben nhan co cho phep nhan thong bao hay khong tu ben gui hay ko
      final bool isEnableNotify =
          receiveUser.EnableNotify!.contains(currentUser.id);
      if (!isEnableNotify) {
        return;
      }

      final String keyServer = await getAccessToken();
      final body = {
        "message": {
          "token": receiveUser.pushToken!,
          "notification": {"body": message, "title": receiveUser.userName},
          "data": {"senderID": currentUser.id},
        }
      };
      var headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $keyServer'
      };
      final response = await http.post(
          Uri.parse(dotenv.env['URL_SEND_NOTIFICATION']!),
          headers: headers,
          body: jsonEncode(body));
      print(keyServer);
      print("response status: ${response.statusCode}");
      print("response body: ${response.body}");
    } catch (e) {
      print(e.toString());
      throw Exception(e);
    }
  }

  @override
  Future<void> allowNotify(String idUser) async {
    // luu id , ko luu token
    try {
      await _firebaseFirestore
          .collection('UserData')
          .doc(_firebaseAuth.currentUser!.uid)
          .update({
        'EnableNotify': FieldValue.arrayUnion([idUser])
      });
    } catch (e) {
      print((e));
      throw Exception(e);
    }
  }

  @override
  Future<void> refuseNotify(String idUser) async {
    try {
      await _firebaseFirestore
          .collection('UserData')
          .doc(_firebaseAuth.currentUser!.uid)
          .update({
        'EnableNotify': FieldValue.arrayRemove([idUser])
      });
    } catch (e) {
      print((e));
      throw Exception(e);
    }
  }

  @override
  Future<void> seenMessage(String ID2) async {
    try {
      final genID = [_firebaseAuth.currentUser!.uid, ID2];
      genID.sort();
      final String chatID = genID.join('_');
      //all mess
      final List<Message> listMess = await _firebaseFirestore
          .collection('Chats')
          .doc(chatID)
          .get()
          .then((snapshot) {
        return ChatRoom.fromJson(snapshot.data()!).listMessage;
      });

      final List<Message?> listNew = listMess.map((mess) {
        if (!mess.seen && mess.senderID == ID2) {
          print(mess.replyingTo);
          return Message(
              senderID: mess.senderID,
              content: mess.content,
              replyingTo: mess.replyingTo,
              type: mess.type,
              sendAt: mess.sendAt,
              tail: mess.tail,
              seen: true);
        } else {
          return Message(
              senderID: mess.senderID,
              content: mess.content,
              replyingTo: mess.replyingTo,
              type: mess.type,
              sendAt: mess.sendAt,
              tail: mess.tail,
              seen: mess.seen);
        }
      }).toList();

      await _firebaseFirestore.collection('Chats').doc(chatID).update(
          {'listMessage': listNew.map((mess) => mess!.toMap()).toList()});
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  @override
  Future<void> unTailMessage(String ID2) async {
    try {
      final genID = [_firebaseAuth.currentUser!.uid, ID2];
      genID.sort();
      final String chatID = genID.join('_');
      //all mess
      final List<Message> listMess = await _firebaseFirestore
          .collection('Chats')
          .doc(chatID)
          .get()
          .then((snapshot) {
        return ChatRoom.fromJson(snapshot.data()!).listMessage;
      });
      //set tail = false
      final List<Message?> listNew = listMess.map((mess) {
        if (mess.tail &&
            mess.senderID != ID2 &&
            mess.sendAt != listMess.last.sendAt) {
          return Message(
              senderID: mess.senderID,
              content: mess.content,
              replyingTo: mess.replyingTo,
              type: mess.type,
              sendAt: mess.sendAt,
              tail: false,
              seen: mess.seen);
        } else {
          return Message(
              senderID: mess.senderID,
              content: mess.content,
              replyingTo: mess.replyingTo,
              type: mess.type,
              sendAt: mess.sendAt,
              tail: mess.tail,
              seen: mess.seen);
        }
      }).toList();
      //save to cloud_firestore
      await _firebaseFirestore.collection('Chats').doc(chatID).update(
          {'listMessage': listNew.map((mess) => mess!.toMap()).toList()});
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteMessage(String ID2, Timestamp time) async {
    try {
      final genID = [_firebaseAuth.currentUser!.uid, ID2];
      genID.sort();
      final String chatID = genID.join('_');
      //all mess
      final List<Message> listMess = await _firebaseFirestore
          .collection('Chats')
          .doc(chatID)
          .get()
          .then((snapshot) {
        return ChatRoom.fromJson(snapshot.data()!).listMessage;
      });
      //delete mess
      final List<Message> listNew =
          listMess.where((mess) => mess.sendAt != time).toList();
      //save to cloud_firestore
      await _firebaseFirestore.collection('Chats').doc(chatID).update(
          {'listMessage': listNew.map((mess) => mess.toMap()).toList()});
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }
}
