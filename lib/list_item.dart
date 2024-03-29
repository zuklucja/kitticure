import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitticure/custom_cache_manager.dart';
import 'package:kitticure/posts.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:kitticure/services/firestore_service.dart';
import 'package:kitticure/services/storage_service.dart';

class ListItem extends StatelessWidget {
  const ListItem(
      {super.key, required this.post, required this.currentUserLogin});

  final Post post;
  final String currentUserLogin;

  @override
  Widget build(BuildContext context) {
    Widget image = post.photoURL != null
        ? CachedNetworkImage(
            cacheManager: CustomCacheManager(),
            imageUrl: post.photoURL!,
          )
        : const Center(
            child: CircularProgressIndicator(
              color: Colors.brown,
            ),
          );

    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width < 500
              ? MediaQuery.of(context).size.width
              : 500,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(60, 83, 83, 83),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoginBar(
                    currentUserLogin: currentUserLogin,
                    post: post,
                  ),
                  const SizedBox(width: 5),
                  image,
                  const SizedBox(width: 5),
                  FavoriteButtonBar(
                    post: post,
                    currentUserLogin: currentUserLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FavoriteButtonBar extends StatefulWidget {
  const FavoriteButtonBar({
    super.key,
    required this.post,
    required this.currentUserLogin,
  });

  final Post post;
  final String currentUserLogin;

  @override
  State<FavoriteButtonBar> createState() => _FavoriteButtonBarState();
}

class _FavoriteButtonBarState extends State<FavoriteButtonBar> {
  User? user = FirebaseAuth.instance.currentUser;
  bool isFavorite = false;

  final Firestore firestore = Firestore();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firestore.isFavouritePost(
          widget.currentUserLogin, widget.post.postId),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          isFavorite = snapshot.data!;
          return Container(
            alignment: Alignment.bottomLeft,
            child: FavoriteButton(
              isFavorite: isFavorite,
              valueChanged: (_) {
                if (isFavorite) {
                  isFavorite = false;
                  if (user != null) {
                    firestore.deleteFavouritePost(
                        widget.currentUserLogin, widget.post.postId);
                  }
                } else {
                  isFavorite = true;
                  if (user != null) {
                    firestore.addFavouritePost(
                        widget.currentUserLogin, widget.post.postId);
                  }
                }
              },
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class LoginBar extends StatelessWidget {
  const LoginBar(
      {super.key, required this.post, required this.currentUserLogin});
  final Post post;
  final String currentUserLogin;

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
                  builder: (context) => DeletePostDialog(post: post));
            }),
            icon: const Icon(Icons.more_horiz),
          ),
      ],
    );
  }
}

class DeletePostDialog extends StatelessWidget {
  DeletePostDialog({super.key, required this.post});

  final Storage storage = Storage();
  final Firestore firestore = Firestore();
  final Post post;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: (() {
            removePost(post);
            Navigator.of(context).pop();
          }),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Usuń post',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> removePost(Post post) async {
    storage.deleteFile(post.postId);
    firestore.deletePost(post.postId);
  }
}
