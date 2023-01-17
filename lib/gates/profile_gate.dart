import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitticure/profile.dart';
import 'package:kitticure/cubits/profile_cubit.dart';
import 'package:kitticure/services/profile_service.dart';
import 'package:provider/provider.dart';

class ProfileGate extends StatelessWidget {
  ProfileGate({super.key, required this.login, required this.isFromSearch});

  final String login;
  final User? user = FirebaseAuth.instance.currentUser;
  final bool isFromSearch;

  @override
  Widget build(BuildContext context) {
    return user != null
        ? Provider(
            create: (_) => ProfileService(),
            child: BlocProvider(
              create: (context) => ProfileCubit(
                profileService: context.read(),
              ),
              child: BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                if (state is GridState) {
                  return GridWidget(
                    login: login,
                    isFromSearch: isFromSearch,
                  );
                } else if (state is PictureState) {
                  return PictureItem(
                    state: state,
                  );
                } else {
                  return const SizedBox();
                }
              }),
            ),
          )
        : const Center(
            child: Text('Zaloguj się'),
          );
  }
}