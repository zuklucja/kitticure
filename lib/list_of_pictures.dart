import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitticure/list_item.dart';
import 'package:kitticure/posts.dart';
import 'services/firestore_service.dart';

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
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.brown,
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: ((context, index) => ListItem(
                          post: snapshot.data?.docs[index].data() as Post,
                          currentUserLogin: snapshotFB.data as String,
                        )),
                  );
                }
              });
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.brown,
            ),
          );
        }
      }),
    );
  }
}