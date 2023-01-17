import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitticure/cubits/auth_cubit.dart';
import 'package:kitticure/gates/profile_gate.dart';
import 'package:kitticure/gates/search_gate.dart';
import 'package:kitticure/services/firestore_service.dart';
import 'package:kitticure/list_of_pictures.dart';
import 'package:kitticure/add_post.dart';

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
    ProfileGate(
      login: "",
      isFromSearch: false,
    ),
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
                selectedItemColor: Colors.brown,
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
                        ? ProfileGate(
                            login: snapshot.data!,
                            isFromSearch: false,
                          )
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
