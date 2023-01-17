import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitticure/gates/profile_gate.dart';
import 'package:kitticure/cubits/search_cubit.dart';
import 'package:kitticure/search_page.dart';
import 'package:kitticure/services/search_service.dart';
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
                return ProfileGate(
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