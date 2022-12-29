import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitticure/firestore_service.dart';
import 'package:kitticure/profile.dart';
import 'package:kitticure/search_cubit.dart';

class UserSearch extends SearchDelegate {
  UserSearch({required this.searchCubit});

  SearchCubit searchCubit;
  Firestore firestore = Firestore();
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return const Center(
        child: Text(
          "Wyszukiwana fraza musi być dłuższa niż 2 litery",
        ),
      );
    }

    return StreamBuilder(
      stream: firestore.searchResult(query).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data?.docs.length == 0) {
            return const Center(
              child: Text(
                "Nie znaleziono użytkownika.",
              ),
            );
          } else {
            var results = snapshot.data?.docs;
            if (results != null) {
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(
                    results[index].data().login,
                  ),
                  onTap: () {
                    close(context, results[index].data().login);
                    searchCubit.showProfile(results[index].data().login);
                  },
                ),
              );
            } else {
              return const Center(
                child: Text(
                  "coś poszło nie tak",
                ),
              );
            }
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // method to add search suggestions as the user enters their search term, this is the place to do that.
    return Column();
  }
}
