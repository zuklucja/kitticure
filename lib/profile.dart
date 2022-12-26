import 'package:flutter/material.dart';
import 'package:kitticure/posts.dart';
import 'package:provider/provider.dart';
import 'package:kitticure/listOfPictures.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  Post? selectedPost;
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
    final user = Provider.of<Admin>(context, listen: false).getCurrentUser;
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: user != null
          ? Navigator(
              pages: [
                MaterialPage(
                  key: const ValueKey("GridPage"),
                  child: Scaffold(
                    body: Column(
                      children: [
                        Text(
                          user.login,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'Raleway',
                          ),
                        ),
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(
                              25.0,
                            ),
                          ),
                          child: TabBar(
                            controller: _tabController,
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
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                itemCount: user.posts.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1,
                                ),
                                itemBuilder: ((context, index) => InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedPost = user.posts[index];
                                        });
                                      },
                                      child:
                                          Container(), //user.posts[index].image,
                                    )),
                              ),
                              GridView.builder(
                                shrinkWrap: true,
                                itemCount: user.likedPosts.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1,
                                ),
                                itemBuilder: ((context, index) => InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedPost = user.likedPosts[index];
                                        });
                                      },
                                      child:
                                          Container(), //user.likedPosts[index].image,
                                    )),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                if (selectedPost != null)
                  MaterialPage(
                    key: const ValueKey("ClickPage"),
                    child: Scaffold(
                      appBar: AppBar(
                        title: const Text('Posty'),
                      ),
                      body: ListItem(
                        post: selectedPost as Post,
                      ),
                    ),
                  ),
              ],
              onPopPage: (route, result) {
                if (!route.didPop(result)) {
                  return false;
                }

                setState(() {
                  selectedPost = null;
                });

                return true;
              },
            )
          : const Center(
              child: Text('Zaloguj się'),
            ),
    );
  }
}
