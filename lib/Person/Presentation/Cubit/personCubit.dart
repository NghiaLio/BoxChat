// ignore_for_file: unused_catch_clause

import 'dart:io';

import 'package:chat_app/Authentication/Domains/Repo/UserRepo.dart';
import 'package:chat_app/Person/Presentation/Cubit/personEventState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../Authentication/Domains/Entity/User.dart';
import '../../Domain/Repo/PersonRepo.dart';

class Personcubit extends Cubit<personEventState> {
  final personRepo person_repo;
  final UserRepo userRepo;

  Personcubit({required this.person_repo, required this.userRepo})
      : super(personEventState());

  UserApp? _user;
  List<String>? _listImage;
  UserApp? get currentUser => _user;
  List<String>? get listImage => _listImage;

  Future<UserApp?> getUser() async {
    final user = await userRepo.getCurrentUser();
    _user = user;
    emit(updateSuccess(user));
    return null;
  }

  //check image in storage of supabase
  Future<bool> checkImage(String nameImage, String currentUserID) async {
    try {
      final String path_storage = '$currentUserID/';
      final listFiles = await Supabase.instance.client.storage
          .from('avatar')
          .list(path: path_storage);
      return listFiles.any((file) => file.name == nameImage);
    } on Exception catch (e) {
      return false;
    }
  }

  // upload image to storage of supabase
  Future<void> uploadImage(
      String nameImage, String currentUserID, File file) async {
    try {
      final String path_storage = '$currentUserID/$nameImage';
      await Supabase.instance.client.storage
          .from('avatar')
          .upload(path_storage, file);
    } catch (e) {
      throw Exception(e);
    }
  }

  //get imageURL from storage of supabase
  Future<String> getImageUrl(String nameImage, String currentUserID) async {
    try {
      final String path_storage = '$currentUserID/$nameImage';
      final url = Supabase.instance.client.storage
          .from('avatar')
          .getPublicUrl(path_storage);
      return url;
    } catch (e) {
      throw Exception(e);
    }
  }
  

  Future<void> changeAvatar(String urlImage) async {
    emit(updating());
    try {
      await person_repo.changeAvatar(urlImage);
      UserApp? user = await userRepo.getCurrentUser();
      emit(updateSuccess(user));
    } catch (e) {
      emit(updateFailed());
    }
  }

  Future<void> changeName(String name) async {
    try {
      await person_repo.changeName(name);
      UserApp? user = await userRepo.getCurrentUser();
      emit(updateSuccess(user));
    } catch (e) {
      emit(updateFailed());
    }
  }

  Future<void> changePhone(String phone) async {
    try {
      await person_repo.changePhone(phone);
      UserApp? user = await userRepo.getCurrentUser();
      emit(updateSuccess(user));
    } catch (e) {
      emit(updateFailed());
    }
  }

  Future<void> changeOtherName(String otherName) async {
    try {
      await person_repo.changeOtherName(otherName);
      UserApp? user = await userRepo.getCurrentUser();
      emit(updateSuccess(user));
    } catch (e) {
      emit(updateFailed());
    }
  }

  Future<void> changeAddress(String otherName) async {
    try {
      await person_repo.changeAddress(otherName);
      UserApp? user = await userRepo.getCurrentUser();
      emit(updateSuccess(user));
    } catch (e) {
      emit(updateFailed());
    }
  }
}
