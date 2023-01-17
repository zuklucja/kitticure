import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String ownerLogin;
  final Timestamp date;
  final String postId;
  final String photoURL;

  Post(
      {required this.ownerLogin,
      required this.date,
      required this.postId,
      required this.photoURL});

  Post.fromJson(Map<String, Object?> json, String postId)
      : this(
            ownerLogin: json['ownerLogin'] as String,
            date: json['date'] as Timestamp,
            postId: postId,
            photoURL: json['photoURL'] as String);

  Map<String, Object?> toJson() {
    return {'ownerLogin': ownerLogin, 'date': date, 'photoURL': photoURL};
  }
}
