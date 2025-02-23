import 'package:chat_app/Person/Domain/Repo/PersonRepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Persondata implements personRepo {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<void> changeAvatar(String urlImage) async {
    await _firestore
        .collection('UserData')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({'avatar': urlImage});
  }

  @override
  Future<void> changeName(String name)async {
    await _firestore
        .collection('UserData')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({'userName': name});
  }

  @override
  Future<void> changePhone(String phone)async {
    await _firestore
        .collection('UserData')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({'phoneNumber': phone});
  }

  @override
  Future<void> changeOtherName(String otherName)async {
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
