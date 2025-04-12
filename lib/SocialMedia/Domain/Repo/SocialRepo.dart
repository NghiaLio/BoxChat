
import 'package:chat_app/SocialMedia/Domain/Entities/comment.dart';
import 'package:chat_app/SocialMedia/Domain/Entities/likes.dart';
import 'package:chat_app/SocialMedia/Domain/Entities/post.dart';


abstract class SocialRepo{
  Stream<List<Map<String, dynamic>>> getAllSocialPost();
  Future<void> createPost(Posts post);
  Future<void> deletePost(int postID);
  Future<void> editPost(Posts post);
  Future<List<Likes>?> getAllLikeForPost(int post_id);
  Future<void> like(Likes like);
  Future<void> unLike(String userID, int postID);
  Future<List<Comments>?> getAllCommentForPost(int postID);
  Future<void> comment(Comments comment);
  Future<void> deleteComment(int commentID);
}