import '../../Authentication/Domains/Entity/User.dart';

abstract class FriendsRepo{
  Future<List<UserApp>?> getAllUser();
  Future<UserApp?> getUserByID(String ID);
  Future<List<UserApp>?> getAllFriends();
  Future<List<UserApp>?> getAllRequired();
  Future<void> addFriends(String ID_User);
  Future<void> confirmFriends(String ID_User);
  Future<void> deleteRequired(String ID_UserRequired);
  Future<void> revokeFriendRequest(String ID_FriendRequest);
  Future<void> unFriends(String ID_User);
}