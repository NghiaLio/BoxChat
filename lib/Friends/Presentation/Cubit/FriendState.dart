// ignore_for_file: camel_case_types

import '../../../Authentication/Domains/Entity/User.dart';

abstract class Friendstate {}

class initialFriend extends Friendstate{}

class loadingPageFriend extends Friendstate{}

class loadedPageFriends extends Friendstate{
  List<UserApp>? listRequired;
  List<UserApp>? listFriends;
  List<UserApp>? listUser;
  
  loadedPageFriends({required this.listFriends,required this.listRequired,required this.listUser});

  loadedPageFriends copyWith({List<UserApp>? listRequired,
  List<UserApp>? listFriends}){
    return loadedPageFriends(
      listFriends: listFriends ?? this.listFriends, 
      listRequired:listRequired ?? this.listRequired, 
      listUser: listUser
    );
  }
}

class haveAnError extends Friendstate{}