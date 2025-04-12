import 'package:chat_app/Chat/Presentation/Cubit/FriendBloc/FriendState.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../Authentication/Domains/Entity/User.dart';
import '../../../Domain/Repo/ChatRepo.dart';

class ListFriendcubit extends Cubit<ListFriendstate> {
  final ChatRepo chatRepo;
  ListFriendcubit({required this.chatRepo}) : super(initialListFriendState());

  List<UserApp>? _listFriends;
  List<UserApp>? get listFriends => _listFriends;

  //getAllFriends
  Future<void> getListFriends() async {
    emit(loadingListFriend());
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> Stream_snapshots =
          chatRepo.getAllFriend();
      Stream_snapshots.listen(
          (QuerySnapshot<Map<String, dynamic>> snapshots) async {
        UserApp user = snapshots.docs
            .map((e) => UserApp.fromJson(e.data()))
            .toList()
            .first;
        final List<String>? listFriends = user.friends!;
        if (listFriends!.isNotEmpty) {
          List<UserApp>? parseList =
              await Future.wait(listFriends.map((id) async {
            return await chatRepo.getUserbyID(id);
          }));
          _listFriends = parseList;
          emit(getListFriendSuccess(listFriends: parseList));
        }else{
          emit(getListFriendSuccess(listFriends: null));
        }
        
      }, onError: (error) {
        emit(onErrorListFriend(error.toString()));
      });
    } catch (e) {
      emit(onErrorListFriend(e.toString()));
    }
  }
}