import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitticure/auth_cubit.dart';
import 'package:kitticure/firestore_service.dart';
import 'package:kitticure/searchpage.dart';
import 'package:kitticure/listOfPictures.dart';
import 'package:kitticure/addPost.dart';
import 'package:kitticure/profile.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.state});

  final AuthState state;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = <Widget>[
    ListOfPictures(),
    const SearchGate(),
    const AddPost(),
    Profile(login: "", isFromSearch: false,),
  ];

  Firestore firestore = Firestore();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firestore.getCurrentUserLogin(user?.email),
        builder: ((context, snapshot) {
          return Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                showSelectedLabels: false,
                showUnselectedLabels: false,
                type: BottomNavigationBarType.fixed,
                iconSize: 40,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: "Strona główna",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: "Wyszukiwanie",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add),
                    label: "Dodaj zdjęcie",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: "Profil",
                  ),
                ],
                currentIndex: _selectedIndex, //New
                onTap: _onItemTapped,
              ),
              body: Center(
                child: snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData
                    ? _selectedIndex == 3
                        ? Profile(login: snapshot.data!, isFromSearch: false,)
                        : _pages.elementAt(_selectedIndex)
                    : _pages.elementAt(_selectedIndex),
              ));
        }));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
