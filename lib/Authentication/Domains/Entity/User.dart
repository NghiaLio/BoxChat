class UserApp {
  String id;
  String userName;
  String? phoneNumber;
  String? avatarUrl;
  String? otherName;
  String? address;
  String email;

  UserApp(
      {required this.id,
      required this.userName,
      required this.email,
      this.phoneNumber,
      this.avatarUrl,
      this.otherName,
      this.address});

  //from Json
  factory UserApp.fromJson(Map<String, dynamic> json) {
    return UserApp(
        id: json['id'] as String,
        userName: json['userName'] as String,
        phoneNumber: json['phoneNumber'] ?? '',
        avatarUrl: json['avatar'] ?? '',
        otherName: json['otherName'] ?? '',
        email: json['email'] as String,
        address: json['address'] ?? '');
  }

  //to Json
  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'phoneNumber': phoneNumber,
        'avatar': avatarUrl,
        'otherName': otherName,
        'email': email,
        'address': address
      };
}
