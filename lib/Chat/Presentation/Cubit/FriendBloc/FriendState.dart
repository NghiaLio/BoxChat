// ignore_for_file: camel_case_types

import '../../../../Authentication/Domains/Entity/User.dart';

abstract class ListFriendstate {}

class initialListFriendState extends ListFriendstate {}
class loadingListFriend extends ListFriendstate {}
class getListFriendSuccess extends ListFriendstate {
  final List<UserApp>? listFriends;
  getListFriendSuccess({this.listFriends});
}
class onErrorListFriend extends ListFriendstate {
  final String error;
  onErrorListFriend(this.error);
}