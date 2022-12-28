import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitticure/posts.dart';
import 'package:kitticure/profile_service.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this.profileService})
      : super(
          profileService.isSelectedPicture
              ? PictureState(profileService.selectedPost as Post)
              : const GridState(),
        );

  final ProfileService profileService;

  Future<void> goBack() async {
    profileService.isSelectedPicture = false;
    emit(const GridState());
  }

  Future<void> showPicture(Post post) async {
    profileService.isSelectedPicture = true;
    profileService.selectedPost = post;
    emit(PictureState(profileService.selectedPost as Post));
  }
}

abstract class ProfileState {
  const ProfileState();
}

class GridState extends ProfileState {
  const GridState();
}

class PictureState extends ProfileState {
  const PictureState(this.selectedPost);

  final Post selectedPost;
}
