import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitticure/my_user.dart';
import 'package:kitticure/posts.dart';
import 'package:flutter/foundation.dart';

class Firestore {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> getCurrentUserLogin(String? email) async {
    if (email == null) return "";

    String result = "";
    await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get()
        .then((snapshot) {
      final docs = snapshot.docs;
      final doc = docs.first;
      if (doc.exists) {
        final data = doc.data();
        result = data['login'];
      }
    });
    return result;
  }

  Future<void> deletePost(String postId) async {
    firestore
        .collection('posts')
        .doc(postId)
        .delete()
        .then((value) => debugPrint("Post Deleted"))
        .catchError((error) => debugPrint("Failed to delete post: $error"));
  }

  Future<void> deleteFavouritePost(String login, String postId) async {
    await firestore
        .collection('posts')
        .doc(postId)
        .update({
          'observers': FieldValue.arrayRemove([login])
        })
        .then((value) => debugPrint("Post deleted from favourites"))
        .catchError(
            (error) => debugPrint("Failed to delete post from favourites: $error"));
  }

  Future<void> addFavouritePost(String login, String postId) async {
    await firestore
        .collection('posts')
        .doc(postId)
        .update({
          'observers': FieldValue.arrayUnion([login])
        })
        .then((value) => debugPrint("Post added to favourites"))
        .catchError(
            (error) => debugPrint("Failed to add post to favourites: $error"));
  }

  Future<bool> isFavouritePost(String? login, String postId) async {
    if (login == null) return false;

    bool result = false;
    await firestore.collection('posts').doc(postId).get().then((snapshot) {
      if (snapshot.exists) {
        final val = snapshot.data();
        if (val != null) {
          if (val.containsKey('observers')) {
            final observers = val['observers'];
            if (observers != null) {
              result = observers.contains(login);
            }
          }
        }
      }
    });

    return result;
  }

  Query<Post> getCurrentUserPosts(String currentUserLogin) {
    return firestore
        .collection('posts')
        .where('ownerLogin', isEqualTo: currentUserLogin)
        .orderBy('date', descending: true)
        .withConverter<Post>(
          fromFirestore: (snapshot, _) =>
              Post.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (post, _) => post.toJson(),
        );
  }

  Query<Post> getCurrentUserFavoritePosts(String currentUserLogin) {
    return firestore
        .collection('posts')
        .where('observers', arrayContains: currentUserLogin)
        .orderBy('date', descending: true)
        .withConverter<Post>(
          fromFirestore: (snapshot, _) =>
              Post.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (post, _) => post.toJson(),
        );
  }

  Query<Post> getAllUsersPosts() {
    return firestore
        .collection('posts')
        .orderBy('date', descending: true)
        .withConverter<Post>(
          fromFirestore: (snapshot, _) =>
              Post.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (post, _) => post.toJson(),
        );
  }

  Query<MyUser> searchResult(String query) {
    return firestore
        .collection('users')
        .where('login', isGreaterThanOrEqualTo: query)
        .where('login', isLessThanOrEqualTo: '$query\uf8ff')
        .withConverter<MyUser>(
          fromFirestore: (snapshot, _) => MyUser.fromJson(snapshot.data()!),
          toFirestore: (user, _) => user.toJson(),
        );
  }

  Future<String> addNewPost(String email) async {
    var result = await firestore.collection('posts').add({
      'ownerLogin': await getCurrentUserLogin(email),
      'date': DateTime.now(),
    });
    return result.id;
  }

  Future<void> updateNewPostPhotoURL(String id, String url) async {
    var document = firestore.collection('posts').doc(id);
    await document.update({'photoURL': url});
  }

    Future<bool> doesLoginAlreadyExists(String login) async {
    return firestore
        .collection('users')
        .where('login', isEqualTo: login)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      return querySnapshot.docs.length == 1;
    });
  }
}
