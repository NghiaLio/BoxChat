
abstract class personRepo{
  Future<void> changeAvatar(String urlImage);
  Future<void> changeName(String name);
  Future<void> changePhone(String phone);
  Future<void> changeOtherName(String otherName);
  Future<void> changeAddress(String address);
}