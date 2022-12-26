import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kitticure/posts.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:kitticure/storage-service.dart';
import 'package:path_provider/path_provider.dart';

class ListOfPictures extends StatelessWidget {
  const ListOfPictures({super.key});

  @override
  Widget build(BuildContext context) {
    final posts =
        FirebaseFirestore.instance.collection('posts').withConverter<Post>(
              fromFirestore: (snapshot, _) =>
                  Post.fromJson(snapshot.data()!, snapshot.id),
              toFirestore: (post, _) => post.toJson(),
            );

    posts.orderBy('date').get();
    return StreamBuilder(
        stream: posts.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Coś poszło nie tak');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.brown,
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: ((context, index) => ListItem(
                  post: snapshot.data?.docs[index].data() as Post,
                )),
          );
        });
  }
}

class ListItem extends StatelessWidget {
  ListItem({super.key, required this.post});
  final Post post;
  final Storage storage = Storage();
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String currentUserLogin = getCurrentUserLogin(user?.uid);
    bool isFavorite = isFavouritePost(user?.uid, post);
// spróbuj z :
// https://docs.flutter.dev/cookbook/lists/floating-app-bar
// https://api.flutter.dev/flutter/material/SliverAppBar-class.html
// https://api.flutter.dev/flutter/material/AppBar-class.html
// https://api.flutter.dev/flutter/material/PopupMenuButton-class.html
    return FutureBuilder(
        future: storage.downloadUrl(post.postId),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            Image image = Image.network(snapshot.data!);
            
            return ConstrainedBox(
              constraints: BoxConstraints.tight(const Size(450, 450)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  width: image.width,
                  height: image.height,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color.fromARGB(60, 83, 83, 83)),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              post.ownerLogin,
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (post.ownerLogin == currentUserLogin)
                            IconButton(
                              onPressed: (() {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 8.0, 8.0, 8.0),
                                      child: InkWell(
                                        onTap: (() {
                                          removePost(post);
                                          Navigator.of(context).pop();
                                        }),
                                        child: const Text('Usuń post'),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              icon: const Icon(Icons.more_horiz),
                            ),
                        ],
                      ),
                      const SizedBox(width: 5),
                      ConstrainedBox(
                        constraints: BoxConstraints.tight(const Size(300, 300)),
                        child: image,
                      ),
                      const SizedBox(width: 5),
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: FavoriteButton(
                          isFavorite: isFavorite,
                          valueChanged: (_) {
                            if (isFavorite) {
                              isFavorite = false;
                              if (user != null) {
                                addFavouritePost(user.uid, post);
                              }
                            } else {
                              isFavorite = true;
                              if (user != null) {
                                deleteFavouritePost(user.uid, post);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  String getCurrentUserLogin(String? uid) {
    if (uid == null) return "";

    String result = "";
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        result = data['login'];
      }
    });
    return result;
  }

  Future<void> removePost(Post post) async {
    storage.deleteFile(post.postId);
    FirebaseFirestore.instance
        .collection('posts')
        .doc(post.postId)
        .delete()
        .then((value) => print("Post Deleted"))
        .catchError((error) => print("Failed to delete post: $error"));
  }

  bool isFavouritePost(String? uid, Post post) {
    if (uid == null) return false;

    bool result = false;
    FirebaseFirestore.instance
        .collection('posts')
        .doc(post.postId)
        .collection('users')
        .get()
        .then((snapshot) {
      final iterator = snapshot.docs.iterator;
      while (iterator.moveNext()) {
        if (iterator.current.data()['userId'] == uid) {
          result = true;
          break;
        }
      }
    });

    return result;
  }

  void addFavouritePost(String uid, Post post) {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(uid)
        .collection('users')
        .add({
          'userId': uid,
        })
        .then((value) => print("Post added to favourites"))
        .catchError(
            (error) => print("Failed to add post to favourites: $error"));
  }

  void deleteFavouritePost(String uid, Post post) {
    String? docId = null;
    FirebaseFirestore.instance
        .collection('posts')
        .doc(post.postId)
        .collection('users')
        .get()
        .then((snapshot) {
      final iterator = snapshot.docs.iterator;
      while (iterator.moveNext()) {
        if (iterator.current.data()['userId'] == uid) {
          docId = iterator.current.id;
          break;
        }
      }
    });

    if (docId == null) return;

    FirebaseFirestore.instance
        .collection('posts')
        .doc(post.postId)
        .collection('users')
        .doc(docId)
        .delete()
        .then((value) => print("Post deleted from favourites"))
        .catchError(
            (error) => print("Failed to delete post from favourites: $error"));
  }
}


//  PopupMenuButton(
//               itemBuilder: (context) {
//                 return [
//                   const PopupMenuItem(
//                     value: 'delete',
//                     child: Text('Delete'),
//                   )
//                 ];
//               },
//               onSelected: (String value) {
//                 print('You Click on po up menu item');
//               },
//             ),