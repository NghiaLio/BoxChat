
// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Friends/Domain/FriendsRepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendData implements FriendsRepo {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<UserApp?> getUserByID(String ID) async {
    try {
      UserApp currentUser = await _firebaseFirestore
          .collection('UserData')
          .withConverter(
              fromFirestore: (snapshot, _) =>
                  UserApp.fromJson(snapshot.data()!),
              toFirestore: (user, _) => user.toJson())
          .doc(ID)
          .get()
          .then((snapshots) => snapshots.data()!);
      return currentUser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Future<List<UserApp>?> getAllFriends() async {
    try {
      //get
      UserApp? currentUser = await getUserByID(_firebaseAuth.currentUser!.uid);
      final List<String> idFriends = currentUser!.friends ?? [];
      // getAllFriends
      List<UserApp?> listFriends = await Future.wait(idFriends.map((id) async {
        return await getUserByID(id);
      }));
      return listFriends.whereType<UserApp>().toList();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Future<List<UserApp>?> getAllUser() async {
    try {
      print(_firebaseAuth.currentUser!.uid);
      final List<UserApp> listUser = await _firebaseFirestore
          .collection('UserData')
          .where('id', isNotEqualTo: _firebaseAuth.currentUser!.uid)
          .get()
          .then((snapshot) {
        return snapshot.docs
            .map((value) => UserApp.fromJson(value.data()))
            .toList();
      });
      return listUser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Future<List<UserApp>?> getAllRequired() async {
    try {
      //get
      UserApp? currentUser = await getUserByID(_firebaseAuth.currentUser!.uid);
      final List<String> idRequired = currentUser!.requiredAddFriend ?? [];
      // getAllFriends
      List<UserApp?> listRequired =
          await Future.wait(idRequired.map((id) async {
        return await getUserByID(id);
      }));
      return listRequired.whereType<UserApp>().toList();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Future<void> addFriends(String idUser) async {
    try {
      await _firebaseFirestore.collection('UserData').doc(idUser).update({
        'requiredAddFriend':
            FieldValue.arrayUnion([_firebaseAuth.currentUser!.uid])
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteRequired(String idUserrequired) async {
    try {
      await _firebaseFirestore
          .collection('UserData')
          .doc(_firebaseAuth.currentUser!.uid)
          .update({
        'requiredAddFriend': FieldValue.arrayRemove([idUserrequired])
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> revokeFriendRequest(String ID_FriendRequest) async{
    try {
      await _firebaseFirestore
          .collection('UserData')
          .doc(ID_FriendRequest)
          .update({
        'requiredAddFriend': FieldValue.arrayRemove([_firebaseAuth.currentUser!.uid])
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> confirmFriends(String idUserrequired) async {
    try {
      await _firebaseFirestore
          .collection('UserData')
          .doc(_firebaseAuth.currentUser!.uid)
          .update({
        'friends': FieldValue.arrayUnion([idUserrequired]),
        'requiredAddFriend': FieldValue.arrayRemove([idUserrequired])
      });
      await _firebaseFirestore
          .collection('UserData')
          .doc(idUserrequired)
          .update({
        'friends': FieldValue.arrayUnion([_firebaseAuth.currentUser!.uid]),
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> unFriends(String idUser)async {
    try {
      //remove friend from currentUser
      await _firebaseFirestore
          .collection('UserData')
          .doc(_firebaseAuth.currentUser!.uid)
          .update({
        'friends': FieldValue.arrayRemove([idUser]),
      });
      //remove friend from otherUser
      await _firebaseFirestore
          .collection('UserData')
          .doc(idUser)
          .update({
        'friends': FieldValue.arrayRemove([_firebaseAuth.currentUser!.uid]),
      });
    } catch (e) {
      throw Exception(e);
    }
  }
}
