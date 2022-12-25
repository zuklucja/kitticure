import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kitticure/posts.dart';
import 'package:provider/provider.dart';
import 'package:favorite_button/favorite_button.dart';

class ListOfPictures extends StatelessWidget {
  const ListOfPictures({super.key});

  @override
  Widget build(BuildContext context) {
    final users = Provider.of<Admin>(context, listen: false).getUsers;
    final posts = AllPosts.combineAllPosts(users);

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: ((context, index) => ListItem(
            post: posts[index],
          )),
    );
  }
}

class ListItem extends StatelessWidget {
  const ListItem({super.key, required this.post});
  final Post? post;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Admin>(context, listen: false).getCurrentUser;
    bool isFavorite = user != null ? user.getLikedPosts.contains(post) : false;
// spróbuj z :
// https://docs.flutter.dev/cookbook/lists/floating-app-bar
// https://api.flutter.dev/flutter/material/SliverAppBar-class.html
// https://api.flutter.dev/flutter/material/AppBar-class.html
// https://api.flutter.dev/flutter/material/PopupMenuButton-class.html
    return ConstrainedBox(
      constraints: BoxConstraints.tight(const Size(450, 450)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: post!.image.width,
          height: post!.image.height,
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(60, 83, 83, 83)),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      post!.user.login,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (post!.user == user)
                    IconButton(
                      onPressed: (() {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                              child: InkWell(
                                onTap: (() {
                                  user!.posts.remove(post);
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
                child: post!.image,
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
                        user.likedPosts.remove(post);
                      }
                    } else {
                      isFavorite = true;
                      if (user != null) {
                        user.addLikedPost(post!);
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