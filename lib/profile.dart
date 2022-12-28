import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitticure/firestore_service.dart';
import 'package:kitticure/posts.dart';
import 'package:kitticure/profile_cubit.dart';
import 'package:kitticure/profile_service.dart';
import 'package:kitticure/storage_service.dart';
import 'package:kitticure/listOfPictures.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  Profile({super.key});

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return user != null
        ? Provider(
            create: (_) => ProfileService(),
            child: BlocProvider(
              create: (context) => ProfileCubit(profileService: context.read()),
              child: BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                if (state is GridState) {
                  return const GridWidget();
                } else if (state is PictureState) {
                  return PictureItem(
                    state: state,
                  );
                } else {
                  return const SizedBox();
                }
              }),
            ),
          )
        : const Center(
            child: Text('Zaloguj się'),
          );
  }
}

class GridWidget extends StatefulWidget {
  const GridWidget({super.key});

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget>
    with SingleTickerProviderStateMixin {
  final Firestore firestore = Firestore();
  final User? user = FirebaseAuth.instance.currentUser;

  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firestore.getCurrentUserLogin(user?.email),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            String currentUserLogin = snapshot.data!;
            final posts = firestore.getCurrentUserPosts(currentUserLogin);
            final favoritePosts =
                firestore.getCurrentUserFavoritePosts(currentUserLogin);
            return MaterialApp(
              theme: ThemeData(
                primarySwatch: Colors.brown,
              ),
              home: Scaffold(
                body: Column(
                  children: [
                    CurrentUserLoginText(login: currentUserLogin),
                    PostsAndFavoritePostsTabBar(
                      tabController: _tabController,
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          StreamBuilder(
                              stream: posts.snapshots(),
                              builder: ((context, snapshot) {
                                if (snapshot.hasData) {
                                  return PicturesGrid(
                                      posts: snapshot.data?.docs);
                                } else {
                                  return Container();
                                }
                              })),
                          StreamBuilder(
                              stream: favoritePosts.snapshots(),
                              builder: ((context, snapshot) {
                                if (snapshot.hasData) {
                                  return PicturesGrid(
                                      posts: snapshot.data?.docs);
                                } else {
                                  return Container();
                                }
                              })),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        }));
  }
}

class CurrentUserLoginText extends StatelessWidget {
  const CurrentUserLoginText({super.key, required this.login});

  final String login;
  @override
  Widget build(BuildContext context) {
    return Text(
      login,
      textAlign: TextAlign.start,
      style: const TextStyle(
        fontSize: 20,
        fontFamily: 'Raleway',
      ),
    );
  }
}

class PostsAndFavoritePostsTabBar extends StatelessWidget {
  const PostsAndFavoritePostsTabBar({super.key, required this.tabController});

  final TabController? tabController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(
          25.0,
        ),
      ),
      child: TabBar(
        controller: tabController,
        // give the indicator a decoration (color and border radius)
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(
            25.0,
          ),
          color: Colors.brown,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        tabs: const [
          Tab(
            text: 'Posty',
          ),
          Tab(
            text: 'Polubione posty',
          ),
        ],
      ),
    );
  }
}

class PicturesGrid extends StatelessWidget {
  PicturesGrid({super.key, required this.posts});

  final List<QueryDocumentSnapshot<Post>>? posts;
  final Storage storage = Storage();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: posts?.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
      ),
      itemBuilder: ((context, index) => FutureBuilder(
          future: storage.downloadUrl((posts?[index].data() as Post).postId),
          builder: ((context, snapshot2) {
            if (snapshot2.connectionState == ConnectionState.done &&
                snapshot2.hasData) {
              return InkWell(
                onTap: () {
                  context
                      .read<ProfileCubit>()
                      .showPicture(posts?[index].data() as Post);
                },
                child: Image.network(snapshot2.data!),
              );
            } else {
              return Container();
            }
          }))),
    );
  }
}

class PictureItem extends StatelessWidget {
  PictureItem({super.key, required this.state});

  final Firestore firestore = Firestore();
  final User? user = FirebaseAuth.instance.currentUser;
  final PictureState? state;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posty'),
        leading: IconButton(
          onPressed: () {
            context.read<ProfileCubit>().goBack();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder(
        future: firestore.getCurrentUserLogin(user?.email),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return ListItem(
              post: state?.selectedPost as Post,
              currentUserLogin: snapshot.data!,
            );
          } else {
            return Container();
          }
        }),
      ),
    );
  }
}
