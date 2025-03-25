import 'package:chat_app/Person/Domain/Repo/PersonRepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Persondata implements personRepo {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final databasePost = Supabase.instance.client.from('social_post');
  final databaseComment = Supabase.instance.client.from('comments');

  @override
  Future<void> changeAvatar(String urlImage) async {
    final Future<void> changeDataUser = _firestore
        .collection('UserData')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({'avatar': urlImage});
    final Future<void> changeDataPost = databasePost
        .update({'image_user_url': urlImage}).eq(
            'user_id', _firebaseAuth.currentUser!.uid);
    final Future<void> changeDataComment = databaseComment
        .update({'image_user_url': urlImage}).eq(
            'user_id', _firebaseAuth.currentUser!.uid);
    await Future.wait([changeDataUser, changeDataPost, changeDataComment]);
  }

  @override
  Future<void> changeName(String name) async {
    final Future<void> changeDataUser = _firestore
        .collection('UserData')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({'userName': name});
    final Future<void> changeDataPost = databasePost.update(
        {'user_name': name}).eq('user_id', _firebaseAuth.currentUser!.uid);
    final Future<void> changeDataComment = databaseComment.update(
        {'user_name': name}).eq('user_id', _firebaseAuth.currentUser!.uid);

    await Future.wait([changeDataUser, changeDataPost, changeDataComment]);
  }

  @override
  Future<void> changePhone(String phone) async {
    await _firestore
        .collection('UserData')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({'phoneNumber': phone});
  }

  @override
  Future<void> changeOtherName(String otherName) async {
    await _firestore
        .collection('UserData')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({'otherName': otherName});
  }

  @override
  Future<void> changeAddress(String address) async {
    await _firestore
        .collection('UserData')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({'address': address});
  }
}
