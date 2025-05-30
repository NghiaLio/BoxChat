// ignore_for_file: avoid_print

import 'dart:io';

import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/SocialMedia/Domain/Entities/comment.dart';
import 'package:chat_app/SocialMedia/Domain/Repo/SocialRepo.dart';
import 'package:chat_app/SocialMedia/Presentation/Cubits/SocialState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Domain/Entities/likes.dart';
import '../../Domain/Entities/post.dart';

class Socialcubits extends Cubit<Socialstate> {
  final SocialRepo socialRepo;
  Socialcubits({required this.socialRepo}) : super(initialSocialState());



  //check image in storage of supabase
  Future<bool> checkImage(
      String nameImage, String currentUserID, String nameStorage) async {
    try {
      final String pathStorage = '$currentUserID/';
      final listFiles = await Supabase.instance.client.storage
          .from(nameStorage)
          .list(path: pathStorage);
      final x = listFiles.any((file) => file.name == nameImage);
      return x;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  // upload image to storage of supabase
  Future<void> uploadImage(String nameImage, String currentUserID, File file,
      String nameStorage) async {
    try {
      final String pathStorage = '$currentUserID/$nameImage';
      await Supabase.instance.client.storage
          .from(nameStorage)
          .upload(pathStorage, file);
    } catch (e) {
      throw Exception(e);
    }
  }

  //get imageURL from storage of supabase
  Future<String> getImageUrl(
      String nameImage, String currentUserID, String nameStorage) async {
    try {
      final String pathStorage = '$currentUserID/$nameImage';
      final url = Supabase.instance.client.storage
          .from(nameStorage)
          .getPublicUrl(pathStorage);
      return url;
    } catch (e) {
      throw Exception(e);
    }
  }

  //createPost
  Future<void> createPost(
      String content, UserApp? user, String? image, File? file) async {
    // ignore: unused_local_variable
    String imageUrl = '';
    if (image != null) {
      final bool isExistImage = await checkImage(image, user!.id, 'post');
      if (!isExistImage) {
        await uploadImage(image, user.id, file!, 'post');
      }
      imageUrl = await getImageUrl(image, user.id, 'post');
    }
    final Posts post = Posts(
        content: content,
        image_user_url: user!.avatarUrl!,
        post_image_url: imageUrl,
        user_id: user.id,
        user_name: user.userName);

    await socialRepo.createPost(post);
    await getAllPost(false);
  }

  //deletePost
  Future<void> deletePost(int postId) async {
    try {
      await socialRepo.deletePost(postId);
      getAllPost(false);
    } catch (e) {
      throw Exception(e);
    }
  }

  //updatePost
  Future<void> updatePost(String content, UserApp? user, String? image,
      File? file, Posts postPrevious) async {
    try {
      String imageUrl = '';
      if (image != null) {
        final bool isExistImage = await checkImage(image, user!.id, 'post');
        if (!isExistImage) {
          await uploadImage(image, user.id, file!, 'post');
        }
        imageUrl = await getImageUrl(image, user.id, 'post');
      }
      final Posts post = Posts(
        id: postPrevious.id,
        created_at: postPrevious.created_at,
        content: content,
        image_user_url: user!.avatarUrl!,
        post_image_url: imageUrl,
        user_id: user.id,
        user_name: user.userName,
        listAnswerOfComments: postPrevious.listAnswerOfComments,
        listComments: postPrevious.listComments,
        listLikes: postPrevious.listLikes,
      );
      await socialRepo.editPost(post);
      getAllPost(false);
    } catch (e) {
      throw Exception(e);
    }
  }

  //getAllSocialPost
  Future<List<Posts>?> getAllPost(bool isLoading) async {
    try {
      isLoading ? emit(loadingPost()) : null;
      final stream = socialRepo.getAllSocialPost();
      stream.listen((List<Map<String, dynamic>> snapshot) async {
        List<Posts>? listPost =
            snapshot.map((value) => Posts.fromJson(value)).toList();
        for (var i = 0; i < listPost.length; i++) {
          List<Likes> listLike = await getAllLikeForPost(listPost[i].id!);
          List<Comments> listComments =
              await getAllCommentForPost(listPost[i].id!);
          List<Comments> listAnswerOfComments =
              listComments.where((cmt) => cmt.answerComment != null).toList();

          listPost[i] = listPost[i].copyWith(
              listLikes: listLike,
              listComments: listComments,
              listAnswerOfComments: listAnswerOfComments);
        }

        emit(loadedPost(listPost));
      }, onError: (error) {
        print(error.toString());
        emit(loadFail());
      });
    } catch (e) {
      print(e.toString() + 'vbv');
      emit(loadFail());
    }
    return null;
  }

  //get all like for post
  Future<List<Likes>> getAllLikeForPost(int postId) async {
    //get all like
    try {
      List<Likes>? listLike = await socialRepo.getAllLikeForPost(postId);
      if (listLike == null) return [];
      return listLike;
    } catch (e) {
      throw Exception(e);
    }
  }

  //get all comment for post
  Future<List<Comments>> getAllCommentForPost(int postId) async {
    try {
      List<Comments>? listComments =
          await socialRepo.getAllCommentForPost(postId);
      if (listComments == null) return [];
      return listComments;
    } catch (e) {
      throw Exception(e);
    }
  }

  //toggle like post
  Future<void> toggleLikePost(int postId, String userId) async {
    try {
      //check like
      final isExistLike = await Supabase.instance.client
          .from('likes')
          .select()
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle(); // Trả về null nếu không có dữ liệu
      if (isExistLike != null) {
        await socialRepo.unLike(userId, postId);
      } else {
        final Likes like = Likes(post_id: postId, user_id: userId);
        await socialRepo.like(like);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //comment
  Future<void> comment(Comments cmt) async {
    try {
      if (cmt.imageCmtUrl!.isEmpty) {}
      await socialRepo.comment(cmt);
      getAllPost(false);
    } catch (e) {
      throw Exception(e);
    }
  }

  //deleteComment
  Future<void> deleteComment(int commentID) async {
    try {
      await socialRepo.deleteComment(commentID);
    } catch (e) {
      throw Exception(e);
    }
  }
}
