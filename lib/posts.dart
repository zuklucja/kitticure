import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class Post {
  final String ownerLogin;
  final Timestamp date;
  final String postId;

  Post({required this.ownerLogin, required this.date, required this.postId});

  Post.fromJson(Map<String, Object?> json, String postId)
      : this(
            ownerLogin: json['ownerLogin'] as String,
            date: json['date'] as Timestamp,
            postId: postId);

  Map<String, Object?> toJson() {
    return {
      'ownerLogin': ownerLogin,
      'date': date,
    };
  }
}

class MyUser {
  final String emailAddress;
  final String login;
  List<Post> posts = [];
  List<Post> likedPosts = [];

  MyUser({required this.emailAddress, required this.login});
  void addPost(Image image) {
    posts.add(Post(ownerLogin: login, date: Timestamp.now(), postId: ""));
    posts.sort((a, b) => b.date.compareTo(a.date));
  }

  List<Post> get getPosts => posts;
  List<Post> get getLikedPosts => likedPosts;
  MyUser get getCurrentUser => this;
  void addLikedPost(Post post) {
    likedPosts.add(post);
    likedPosts.sort((a, b) => b.date.compareTo(a.date));
  }
}

class Admin extends ChangeNotifier {
  final List<MyUser> users = [];
  late MyUser admin;
  MyUser? currentUser;

  void addUser(MyUser user) {
    users.add(user);
    notifyListeners();
  }

  List<MyUser> get getUsers => users;
  MyUser? get getCurrentUser => currentUser;
  void setCurrentUser(MyUser? user) {
    currentUser = user;
    notifyListeners();
  }

  MyUser? findUser(String emailAddress) {
    for (int i = 0; i < users.length; i++) {
      if (users[i].emailAddress == emailAddress) {
        return users[i];
      }
    }
    return null;
  }

  Admin() {
    // admin = MyUser(login: 'Kitticure', password: 'pass1');
    // Generator.generatePosts(10, admin);
    // addUser(admin);
    // sleep(const Duration(seconds: 1));
    // final user = MyUser(login: 'admin', password: 'pass');
    // Generator.generatePosts(5, user);
    // addUser(user);
  }
}

class AllPosts {
  static List<Post> combineAllPosts(List<MyUser> users) {
    List<Post> allPosts = [];
    users.forEach((user) => allPosts.addAll(user.posts));
    allPosts.sort((a, b) => b.date.compareTo(a.date));
    return allPosts;
  }
}

class Generator {
  static void generatePosts(int number, MyUser user) {
    for (int i = 0; i < number; i++) {
      user.addPost(
        Image.network("https://placekitten.com/300/300?${4 * i + 200}"),
      );
    }
  }
}
