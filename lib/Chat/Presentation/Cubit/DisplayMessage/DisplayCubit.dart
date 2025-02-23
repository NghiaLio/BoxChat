import 'dart:io';

import 'package:chat_app/Chat/Domain/Models/ChatRoom.dart';
import 'package:chat_app/Chat/Domain/Models/Message.dart';
import 'package:chat_app/Chat/Domain/Repo/ChatRepo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'DisplayState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DisplayCubit extends Cubit<DisplayState> {
  DisplayCubit({required this.chatRepo}) : super(initialDisplay());

  final ChatRepo chatRepo;

  static const path_storage = 'imageOfChat/';

  List<Message>? _listMessage;
  List<Message>? get listMess => _listMessage;
  int? _indexSelected;
  int? get indexSelected => _indexSelected;
  //Get message
  Future<List<Message>?> getMessageList(String ID2) async {
    emit(loadingMessage());
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> Stream_snapshots =
          chatRepo.getMessage(ID2);
      Stream_snapshots.listen((QuerySnapshot<Map<String, dynamic>> snapshots) {
        ChatRoom chat = ChatRoom.fromJson(snapshots.docs.first.data());
        List<Message>? parseList = chat.listMessage;
        _listMessage = parseList;
        emit(loadedMessage(parseList));
      }, onError: (error) {
        print(error.toString());
        emit(loadFailMessage(error.toString()));
        return null;
      });
      return _listMessage;
    } catch (e) {
      print(e);
      emit(loadFailMessage(e.toString()));
      return null;
    }
  }

  //send Mesage
  Future<void> sendMess(Message mess, String ID2) async {
    await chatRepo.sendMessage(mess, ID2);
  }

  //upload image to storage of supabase
  Future<void> uploadImage(String nameImage, File file, String chatID) async {
    final pathImage = '$path_storage$chatID/$nameImage';
    await Supabase.instance.client.storage
        .from('images')
        .upload(pathImage, file);
  }

  //get image url from storage of supabase
  Future<String> getImageUrl(String nameImage, String chatID) async {
    final pathImage = '$path_storage$chatID/$nameImage';
    final url = Supabase.instance.client.storage
        .from('images')
        .getPublicUrl(pathImage);
    return url;
  }

  //check image in storage of supabase
  Future<bool> checkImage(String nameImage, String ChatID) async {
    try {
      final listFiles = await Supabase.instance.client.storage
          .from('images')
          .list(path: '$path_storage$ChatID/');
      return listFiles.any((file) => file.name == nameImage);
    } on Exception catch (e) {
      return false;
    }
  }

  //selected Message
  void selectedMessage(int? indexMessage) {
    _indexSelected = indexMessage;
  }

  //reply Message
  void replyMessage(int? indexMessage) {}
}
