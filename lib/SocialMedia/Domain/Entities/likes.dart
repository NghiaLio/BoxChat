class Likes {
  int? id;
  DateTime? created_at;
  String user_id;
  int post_id;

  Likes(
      {this.id,
      this.created_at,
      required this.post_id,
      required this.user_id});

  factory Likes.fromJson(Map<String, dynamic> json) {
    return Likes(
        id: json['id'],
        created_at: DateTime.parse(json['created_at']),
        post_id: json['post_id'],
        user_id: json['user_id']);
  }

  Map<String, dynamic> toJson() =>{
    "user_id": user_id,
    'post_id':post_id
  };
}
