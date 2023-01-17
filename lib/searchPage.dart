import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitticure/profile.dart';
import 'package:kitticure/search_cubit.dart';
import 'package:kitticure/search_service.dart';
import 'package:kitticure/user_search.dart';
import 'package:provider/provider.dart';

class SearchGate extends StatelessWidget {
  const SearchGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (_) => SearchService(),
        child: BlocProvider(
          create: (context) => SearchCubit(searchService: context.read()),
          child: BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              if (state is ListState) {
                return const SearchPage();
              } else if (state is SearchedProfileState) {
                return Profile(
                  login: state.searchedUserLogin,
                  isFromSearch: true,
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ));
  }
}

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
