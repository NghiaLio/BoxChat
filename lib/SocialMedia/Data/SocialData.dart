import 'package:chat_app/SocialMedia/Domain/Entities/comment.dart';
import 'package:chat_app/SocialMedia/Domain/Entities/likes.dart';
import 'package:chat_app/SocialMedia/Domain/Entities/post.dart';
import 'package:chat_app/SocialMedia/Domain/Repo/SocialRepo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Socialdata implements SocialRepo {
  final databasePost = Supabase.instance.client.from('social_post');
  final databaseLike = Supabase.instance.client.from('likes');
  final databaseComment = Supabase.instance.client.from('comments');


  @override
  Future<void> createPost(Posts post) async {
    try {
      await databasePost.insert(post.toJson());
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getAllSocialPost() {
    return databasePost
        .stream(primaryKey: ['id']).order('created_at', ascending: false);
  }

  @override
  Future<void> deletePost(int postID) async {
    try {
      await databasePost.delete().eq('id', postID);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> editPost(Posts post) async{
    try {
      await databasePost.update(post.toJson()).eq('id', post.id!);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> like(Likes like) async {
    await databaseLike.insert(like.toJson());
  }

  @override
  Future<void> unLike(String userID, int postID) async {
    await databaseLike.delete().eq('post_id', postID).eq('user_id', userID);
  }

  @override
  Future<List<Likes>?> getAllLikeForPost(int post_id) async {
    final data = await databaseLike.select().eq('post_id', post_id);
    final List<Likes>? listLike = data.map((e) => Likes.fromJson(e)).toList();
    return listLike;
  }

  @override
  Future<List<Comments>?> getAllCommentForPost(int postID) async {
    final data = await databaseComment.select().eq('post_id', postID);
    final List<Comments> listComments =
        data.map((e) => Comments.fromJson(e)).toList();
    return listComments;
  }

  @override
  Future<void> comment(Comments comment) async {
    await databaseComment.insert(comment.toJson());
  }

  @override
  Future<void> deleteComment(int commentID) async {
    await databaseComment.delete().eq('id', commentID);
  }
}
