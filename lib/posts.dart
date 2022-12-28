import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String ownerLogin;
  final Timestamp date;
  final String postId;

  Post({required this.ownerLogin, required this.date, required this.postId});

  Post.fromJson(Map<String, Object?> json, String postId)
      : this(
            ownerLogin: json['ownerLogin'] as String,
            date: json['date'] as Timestamp,
            postId: postId);

  Map<String, Object?> toJson() {
    return {
      'ownerLogin': ownerLogin,
      'date': date,
    };
  }
}
