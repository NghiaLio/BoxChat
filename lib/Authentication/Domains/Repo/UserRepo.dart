import '../Entity/User.dart';

abstract class UserRepo{
  Future<UserApp?> login(String email, String password);
  Future<UserApp?> register(String name, String email, String password);
  Future<void> logOut();
  Future<void> updateOnline(bool isOnline);
  Future<UserApp?> getCurrentUser();
  Future<List<UserApp>?> getAlluser();
  Future<String?> resetPassword(String email);
  Future<void> getFirebaseMessagingToken();
}