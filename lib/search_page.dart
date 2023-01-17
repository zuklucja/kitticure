import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitticure/cubits/search_cubit.dart';
import 'package:kitticure/user_search.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.brown,
          floating: true,
          snap: true,
          title: const Text("Wyszukaj użytkownika"),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate:
                      UserSearch(searchCubit: context.read<SearchCubit>()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
