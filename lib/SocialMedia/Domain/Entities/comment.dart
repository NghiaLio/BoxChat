class Comments {
  int? id;
  DateTime? created_at;
  String user_name;
  String user_id;
  String content;
  String imageUserUrl;
  String? imageCmtUrl;
  int post_id;
  int? answerComment;

  Comments(
      {this.id,
      this.created_at,
      required this.content,
      required this.user_name,
      required this.user_id,
      required this.post_id,
      required this.imageUserUrl,
      this.imageCmtUrl,
      this.answerComment
      });

  factory Comments.fromJson(Map<String , dynamic> json){
    return Comments(
      id: json['id'],
      created_at: DateTime.parse(json['created_at']),
      content: json['content_comment'], 
      user_name: json['user_name'], 
      user_id: json['user_id'], 
      post_id: json['post_id'], 
      imageUserUrl: json['image_user_url'],
      imageCmtUrl: json['image_url'] ?? '',
      answerComment: json['answer_comment_id']
      );
  }

  Map<String, dynamic> toJson()=>{
    'content_comment':content,
    'user_name': user_name,
    'user_id': user_id,
    'post_id': post_id,
    'image_user_url':imageUserUrl,
    'image_url': imageCmtUrl,
    'answer_comment_id': answerComment
  };
}
