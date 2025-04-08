// ignore_for_file: non_constant_identifier_names

import 'package:chat_app/SocialMedia/Domain/Entities/comment.dart';
import 'package:chat_app/SocialMedia/Domain/Entities/likes.dart';

class Posts {
  int? id;
  DateTime? created_at;
  String user_id;
  String user_name;
  String content;
  String image_user_url;
  String post_image_url;
  List<Likes>? listLikes;
  List<Comments>? listComments;
  List<Comments>? listAnswerOfComments;

  Posts(
      {this.id,
      this.created_at,
      required this.content,
      required this.image_user_url,
      required this.post_image_url,
      required this.user_id,
      required this.user_name,
      this.listLikes,
      this.listComments,
      this.listAnswerOfComments});

  Posts copyWith(
      {int? id,
      DateTime? created_at,
      String? user_id,
      String? user_name,
      String? content,
      String? image_user_url,
      String? post_image_url,
      List<Likes>? listLikes,
      List<Comments>? listComments,
      List<Comments>? listAnswerOfComments
      }) {
    return Posts(
        id: id ?? this.id,
        created_at: created_at ?? this.created_at,
        content: content ?? this.content,
        image_user_url: image_user_url ?? this.image_user_url,
        post_image_url: post_image_url ?? this.post_image_url,
        user_id: user_id ?? this.user_id,
        user_name: user_id ?? this.user_name,
        listLikes: listLikes ?? this.listLikes,
        listComments: listComments ?? this.listComments,
        listAnswerOfComments: listAnswerOfComments ?? this.listAnswerOfComments
        );
  }

  factory Posts.fromJson(Map<String, dynamic> json) {
    return Posts(
        id: json['id'],
        created_at: DateTime.parse(json['created_at']),
        content: json['content'] ?? '',
        image_user_url: json['image_user_url'] ?? '',
        post_image_url: json['image_post_url'] ?? '',
        user_id: json['user_id'],
        user_name: json['user_name']);
  }

  Map<String, dynamic> toJson() => {
        'content': content,
        'user_id': user_id,
        'user_name': user_name,
        'image_user_url': image_user_url,
        'image_post_url': post_image_url
      };
}
