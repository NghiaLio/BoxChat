import 'package:chat_app/Authentication/Domains/Repo/UserRepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../Domains/Entity/User.dart';

class UserData implements UserRepo {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  @override
  Future<UserApp?> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      //get User
      UserApp? currentUser = await getCurrentUser();

      return currentUser;
    } on FirebaseAuthException catch (e) {
      print("lỗi $e");
      return null;
    }
  }

  @override
  Future<UserApp?> register(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      UserApp currentUser =
          UserApp(id: userCredential.user!.uid, userName: name, email: email);

      //save to cloud store
      await _firebaseFirestore
          .collection('UserData')
          .doc(currentUser.id)
          .set(currentUser.toJson());

      return currentUser;
    } on FirebaseAuthException catch (e) {
      return null;
    }
  }

  @override
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserApp?> getCurrentUser() async {
    try {
      final user = await _firebaseAuth.currentUser;
      if (user == null) {
        return null;
      } else {
        //get
        UserApp currentUser = await _firebaseFirestore
            .collection('UserData')
            .withConverter(
                fromFirestore: (snapshot, _) =>
                    UserApp.fromJson(snapshot.data()!),
                toFirestore: (user, _) => user.toJson())
            .doc(user.uid)
            .get()
            .then((snapshots) => snapshots.data()!);
        return currentUser;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<UserApp>?> getAlluser()async {
    try {
      final List<UserApp> listUser = await _firebaseFirestore
          .collection('UserData')
          .where('id', isNotEqualTo: _firebaseAuth.currentUser!.uid)
          .get()
          .then((value) =>
              value.docs.map((e) => UserApp.fromJson(e.data())).toList())
          .catchError((onError) => throw onError);
      return listUser;
    } catch (e) {
      // throw Exception(e);
      print(e);
      return null;
    }
  }

  //resetPass
  @override
  Future<String?> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return email;
    } on FirebaseAuthException catch (e) {
      return null;
    }
  }

  //for accessing firebase messaging (Push Notification)
  FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  //for getting firebase messaging token
  @override
  Future<String?> getFirebaseMessagingToken() async {
  await fMessaging.requestPermission();
  // print(x.authorizationStatus);
   final String? pushToken = await fMessaging.getToken().then((token) {
      if (token != null) {
        print('token: $token');
        return token;
      }
      
    });
    return pushToken;
  }

  @override
  Future<void> updateOnline(bool isOnline) async {
    final user = await _firebaseAuth.currentUser;
    final String? pushToken = await getFirebaseMessagingToken();
    await _firebaseFirestore.collection('UserData').doc(user!.uid).update({
      'isOnline': isOnline,
      'lastActive': Timestamp.fromDate(DateTime.now()),
      'pushToken': pushToken,
    });
  }
}
