import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Friends/Domain/FriendsRepo.dart';
import 'package:chat_app/Friends/Presentation/Cubit/FriendState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Friendcubit extends Cubit<Friendstate> {
  Friendcubit({required this.friendsRepo}) : super(initialFriend());
  final FriendsRepo friendsRepo;

  //getAllUser
  Future<List<UserApp>?> getAllUser() async {
    return await friendsRepo.getAllUser();
  }

  //getAllFriends
  Future<List<UserApp>?> getAllFriends() async {
    return await friendsRepo.getAllFriends();
  }

  //getAllRequired
  Future<List<UserApp>?> getAllRequired() async {
    return await friendsRepo.getAllRequired();
  }

  //fetch all data for page
  Future<void> fetchData() async {
    try {
      emit(loadingPageFriend());
      final data = await Future.wait([getAllFriends(), getAllRequired()]);
      List<UserApp>? listFriends = data[0];
      List<UserApp>? listRequired = data[1];

      List<UserApp>? listData = await getAllUser() ?? [];

      Set<String> setListFriendsID = listFriends!.map((e)=> e.id).toSet();
      Set<String> setListRequiredID = listRequired!.map((e)=> e.id).toSet();
      List<UserApp>? listUser = listData
          .where((value) =>
              !setListFriendsID.contains(value.id) &&
              !setListRequiredID.contains(value.id))
          .toList();
      emit(loadedPageFriends(
          listFriends: listFriends,
          listRequired: listRequired,
          listUser: listUser));
    } catch (e) {
      throw Exception(e);
    }
  }

  //add friends
  Future<void> addFriends(String ID_User) async {
    await friendsRepo.addFriends(ID_User);
  }

  //deleteRequired
  Future<void> deleteRequired(String ID_UserRequired) async {
    await friendsRepo.deleteRequired(ID_UserRequired);
  }

  //revoke request
  Future<void> revokeRequest(String ID_FriendRequest) async {
    await friendsRepo.revokeFriendRequest(ID_FriendRequest);
  }

  //confirmFriends
  Future<void> confirmFriends(String ID_UserRequired) async {
    await friendsRepo.confirmFriends(ID_UserRequired);
  }

  //unFriends
  Future<void> unFriends(String ID_User) async {
    await friendsRepo.unFriends(ID_User);
  }
}
