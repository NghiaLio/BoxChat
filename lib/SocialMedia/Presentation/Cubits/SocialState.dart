import '../../Domain/Entities/post.dart';

abstract class Socialstate {}

class initialSocialState extends Socialstate{}

class loadingPost extends Socialstate{}

class loadedPost extends Socialstate{
  List<Posts>? listPost;
  loadedPost(this.listPost);
}

class loadFail extends Socialstate{}