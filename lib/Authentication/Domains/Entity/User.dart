import 'package:cloud_firestore/cloud_firestore.dart';

class UserApp {
  String id;
  String userName;
  String? phoneNumber;
  String? avatarUrl;
  String? otherName;
  String? address;
  String email;
  bool? isOnline;
  List<String>? requiredAddFriend;
  List<String>? friends;
  Timestamp? lastActive;
  String? pushToken;
  List<String>? EnableNotify;

  UserApp(
      {required this.id,
      required this.userName,
      required this.email,
      this.phoneNumber,
      this.avatarUrl,
      this.otherName,
      this.address,
      this.isOnline,
      this.requiredAddFriend,
      this.friends,
      this.lastActive, this.pushToken, this.EnableNotify});

  //from Json
  factory UserApp.fromJson(Map<String, dynamic> json) {
    return UserApp(
        id: json['id'] as String,
        userName: json['userName'] as String,
        phoneNumber: json['phoneNumber'] ?? '',
        avatarUrl: json['avatar'] ?? '',
        otherName: json['otherName'] ?? '',
        email: json['email'] as String,
        address: json['address'] ?? '',
        isOnline: json['isOnline'] ?? false,
        requiredAddFriend: List<String>.from(json['requiredAddFriend']?? []) ,
        friends: List<String>.from(json['friends'] ?? []),
        lastActive: json['lastActive'],
        pushToken: json['pushToken'] ?? '',
        EnableNotify: List<String>.from(json['EnableNotify']?? [])
        );
  }

  //to Json
  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'phoneNumber': phoneNumber,
        'avatar': avatarUrl,
        'otherName': otherName,
        'email': email,
        'address': address,
        'isOnline': isOnline,
        'requiredAddFriend': requiredAddFriend,
        'friends': friends,
        'lastActive': lastActive,
        'pushToken':pushToken,
        'EnableNotify':EnableNotify
      };
}
