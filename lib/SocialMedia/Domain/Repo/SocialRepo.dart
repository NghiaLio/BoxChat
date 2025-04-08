
import 'package:chat_app/SocialMedia/Domain/Entities/comment.dart';
import 'package:chat_app/SocialMedia/Domain/Entities/likes.dart';
import 'package:chat_app/SocialMedia/Domain/Entities/post.dart';

import '../../../Authentication/Domains/Entity/User.dart';

abstract class SocialRepo{
  Future<List<UserApp>?> getAllUser(String currentUserID);
  Stream<List<Map<String, dynamic>>> getAllSocialPost();
  Future<void> createPost(Posts post);
  Future<void> deletePost(String userID, String postID);
  Future<List<Likes>?> getAllLikeForPost(int post_id);
  Future<void> like(Likes like);
  Future<void> unLike(String userID, int postID);
  Future<List<Comments>?> getAllCommentForPost(int postID);
  Future<void> comment(Comments comment);
  Future<void> deleteComment(int commentID);
}