import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitticure/firestore_service.dart';
import 'package:kitticure/posts.dart';
import 'package:kitticure/profile_cubit.dart';
import 'package:kitticure/profile_service.dart';
import 'package:kitticure/search_cubit.dart';
import 'package:kitticure/storage_service.dart';
import 'package:kitticure/listOfPictures.dart';
import 'package:provider/provider.dart';

import 'auth_cubit.dart';

class Profile extends StatelessWidget {
  Profile({super.key, required this.login, required this.isFromSearch});

  final String login;
  final User? user = FirebaseAuth.instance.currentUser;
  final bool isFromSearch;

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
                  return GridWidget(
                    login: login,
                    isFromSearch: isFromSearch,
                  );
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
  const GridWidget(
      {super.key, required this.login, required this.isFromSearch});

  final String login;
  final bool isFromSearch;

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
    final posts = firestore.getCurrentUserPosts(widget.login);
    final favoritePosts = firestore.getCurrentUserFavoritePosts(widget.login);
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Profil użytkownika ${widget.login}"),
          leading: widget.isFromSearch
              ? IconButton(
                  onPressed: () {
                    context.read<SearchCubit>().goBack();
                  },
                  icon: const Icon(Icons.arrow_back),
                )
              : IconButton(
                  onPressed: () {
                    context.read<AuthCubit>().signOut();
                  },
                  icon: const Icon(Icons.logout)),
        ),
        body: Column(
          children: [
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
                          return PicturesGrid(posts: snapshot.data?.docs);
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.brown,
                            ),
                          );
                        }
                      })),
                  StreamBuilder(
                      stream: favoritePosts.snapshots(),
                      builder: ((context, snapshot) {
                        if (snapshot.hasData) {
                          return PicturesGrid(posts: snapshot.data?.docs);
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.brown,
                            ),
                          );
                        }
                      })),
                ],
              ),
            )
          ],
        ),
      ),
    );
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
      itemBuilder: ((context, index) => InkWell(
            onTap: () {
              context
                  .read<ProfileCubit>()
                  .showPicture(posts?[index].data() as Post);
            },
            child: Image(
                image: CachedNetworkImageProvider(
                    (posts?[index].data() as Post).photoURL)),
          )),
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
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: Scaffold(
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
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.brown,
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}
