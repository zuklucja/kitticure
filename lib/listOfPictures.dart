import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitticure/posts.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:kitticure/storage_service.dart';

import 'firestore_service.dart';

class ListOfPictures extends StatelessWidget {
  ListOfPictures({super.key});
  final User? user = FirebaseAuth.instance.currentUser;
  final Firestore firestore = Firestore();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firestore.getCurrentUserLogin(user?.email),
      builder: ((context, snapshotFB) {
        if (snapshotFB.connectionState == ConnectionState.done &&
            snapshotFB.hasData) {
          final posts = firestore.getAllUsersPosts();

          return StreamBuilder(
              stream: posts.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Coś poszło nie tak');
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
                        currentUserLogin: snapshotFB.data as String,
                      )),
                );
              });
        } else {
          return Container();
        }
      }),
    );
  }
}

class ListItem extends StatelessWidget {
  ListItem({super.key, required this.post, required this.currentUserLogin});
  final Post post;
  final Storage storage = Storage();
  final Firestore firestore = Firestore();
  User? user = FirebaseAuth.instance.currentUser;
  final String currentUserLogin;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firestore.isFavouritePost(currentUserLogin, post.postId),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            bool isFavorite = snapshot.data!;
            return FutureBuilder(
                future: storage.downloadUrl(post.postId),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    Image image = Image.network(snapshot.data!);

                    return Photo(
                      post: post,
                      image: image,
                      isFavorite: isFavorite,
                      currentUserLogin: currentUserLogin,
                    );
                  } else {
                    return Container();
                  }
                });
          } else {
            return Container();
          }
        });
  }
}

class Photo extends StatelessWidget {
  Photo(
      {super.key,
      required this.isFavorite,
      required this.post,
      required this.image,
      required this.currentUserLogin});

  bool isFavorite;
  final Image image;
  final Post post;
  final String currentUserLogin;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tight(const Size(450, 450)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: image.width,
          height: image.height,
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(60, 83, 83, 83)),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              LoginBar(
                currentUserLogin: currentUserLogin,
                post: post,
              ),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: BoxConstraints.tight(const Size(300, 300)),
                child: image,
              ),
              const SizedBox(width: 5),
              FavoriteButtonBar(
                  isFavorite: isFavorite,
                  post: post,
                  currentUserLogin: currentUserLogin),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteButtonBar extends StatelessWidget {
  FavoriteButtonBar({
    super.key,
    required this.isFavorite,
    required this.post,
    required this.currentUserLogin,
  });

  bool isFavorite;
  final Post post;
  final String currentUserLogin;

  User? user = FirebaseAuth.instance.currentUser;
  final Firestore firestore = Firestore();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      child: FavoriteButton(
        isFavorite: isFavorite,
        valueChanged: (_) {
          if (isFavorite) {
            isFavorite = false;
            if (user != null) {
              firestore.deleteFavouritePost(currentUserLogin, post.postId);
            }
          } else {
            isFavorite = true;
            if (user != null) {
              firestore.addFavouritePost(currentUserLogin, post.postId);
            }
          }
        },
      ),
    );
  }
}

class LoginBar extends StatelessWidget {
  LoginBar({super.key, required this.post, required this.currentUserLogin});
  final Post post;
  final String currentUserLogin;

  final Storage storage = Storage();
  final Firestore firestore = Firestore();

  @override
  Widget build(BuildContext context) {
    return Row(
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
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
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
    );
  }

  Future<void> removePost(Post post) async {
    storage.deleteFile(post.postId);
    firestore.deletePost(post.postId);
  }
}
