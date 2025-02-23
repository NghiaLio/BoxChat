import 'package:chat_app/Authentication/Domains/Entity/User.dart';

abstract class authState{}

class initialAuth extends authState{}

class UnAuthenticated extends authState{}

class Authenticated extends authState{
  UserApp? user;
  Authenticated(this.user);
}

class FailAuth extends authState{
  String mess;
  FailAuth(this.mess);
}