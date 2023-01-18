import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitticure/list_item.dart';
import 'package:kitticure/services/firestore_service.dart';
import 'package:kitticure/posts.dart';
import 'package:kitticure/cubits/profile_cubit.dart';
import 'package:kitticure/cubits/search_cubit.dart';
import 'package:kitticure/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'cubits/auth_cubit.dart';

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
                  Grid(posts: posts),
                  Grid(posts: favoritePosts),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PostsAndFavoritePostsTabBar extends StatelessWidget {
  const PostsAndFavoritePostsTabBar({super.key, required this.tabController});

  final TabController? tabController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(
            25.0,
          ),
        ),
        child: TabBar(
          controller: tabController,
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
      ),
    );
  }
}

class Grid extends StatelessWidget {
  const Grid({
    super.key,
    required this.posts,
  });

  final Query<Post> posts;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
        }));
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
            child: (posts?[index].data() as Post).photoURL != null
                ? Image(
                    image: CachedNetworkImageProvider(
                    (posts?[index].data() as Post).photoURL!,
                  ))
                : const Center(
                    child: CircularProgressIndicator(
                    color: Colors.brown,
                  )),
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
