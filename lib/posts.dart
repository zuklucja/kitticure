import 'package:flutter/material.dart';
import 'dart:io';

class Post {
  final Image image;
  final User user;
  final DateTime date;

  Post({required this.user, required this.image, required this.date});
}

class User {
  final String login;
  final String password;
  List<Post> posts = [];
  List<Post> likedPosts = [];

  User({required this.login, required this.password});
  void addPost(Image image) {
    posts.add(Post(user: this, image: image, date: DateTime.now()));
    posts.sort((a, b) => b.date.compareTo(a.date));
  }

  List<Post> get getPosts => posts;
  List<Post> get getLikedPosts => likedPosts;
  User get getCurrentUser => this;
  void addLikedPost(Post post) {
    likedPosts.add(post);
    likedPosts.sort((a, b) => b.date.compareTo(a.date));
  }
}

class Admin extends ChangeNotifier {
  final List<User> users = [];
  late User admin;
  User? currentUser;

  void addUser(User user) {
    users.add(user);
    notifyListeners();
  }

  List<User> get getUsers => users;
  User? get getCurrentUser => currentUser;
  void setCurrentUser(User? user) {
    currentUser = user;
    notifyListeners();
  }

  User? findUser(String login, String password) {
    for (int i = 0; i < users.length; i++) {
      if (users[i].login == login && users[i].password == password) {
        return users[i];
      }
    }
    return null;
  }

  Admin() {
    admin = User(login: 'Kitticure', password: 'pass1');
    Generator.generatePosts(10, admin);
    addUser(admin);
    sleep(const Duration(seconds: 1));
    final user = User(login: 'admin', password: 'pass');
    Generator.generatePosts(5, user);
    addUser(user);
  }
}

class AllPosts {
  static List<Post> combineAllPosts(List<User> users) {
    List<Post> allPosts = [];
    users.forEach((user) => allPosts.addAll(user.posts));
    allPosts.sort((a, b) => b.date.compareTo(a.date));
    return allPosts;
  }
}

class Generator {
  static void generatePosts(int number, User user) {
    for (int i = 0; i < number; i++) {
      user.addPost(
        Image.network("https://placekitten.com/300/300?${4 * i + 200}"),
      );
    }
  }
}
