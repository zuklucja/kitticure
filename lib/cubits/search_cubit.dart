import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitticure/services/search_service.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({required this.searchService})
      : super(
          searchService.isSelectedProfile
              ? SearchedProfileState(searchService.selectedProfileLogin as String)
              : const ListState(),
        );

  final SearchService searchService;

  Future<void> goBack() async {
    searchService.isSelectedProfile = false;
    emit(const ListState());
  }

  Future<void> showProfile(String login) async {
    searchService.isSelectedProfile = true;
    searchService.selectedProfileLogin = login;
    emit(SearchedProfileState(login));
  }
}

abstract class SearchState {
  const SearchState();
}

class ListState extends SearchState {
  const ListState();
}

class SearchedProfileState extends SearchState {
  const SearchedProfileState(this.searchedUserLogin);

  final String searchedUserLogin;
}
