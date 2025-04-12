// ignore_for_file: non_constant_identifier_names, camel_case_types


import 'package:chat_app/Chat/Domain/Models/ChatRoom.dart';
import 'package:chat_app/Chat/Domain/Models/Message.dart';
import 'package:chat_app/Chat/Presentation/Cubit/FriendBloc/FriendState.dart';
import 'package:chat_app/Chat/Presentation/Cubit/FriendBloc/friendCubit.dart';
import 'package:chat_app/Chat/Presentation/Screen/ChatScreen.dart';
import 'package:chat_app/Chat/Presentation/Screen/SearchUser.dart';
import 'package:chat_app/Components/Avatar.dart';
import 'package:chat_app/Components/CircleProgressIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../Authentication/Domains/Entity/User.dart';
import '../../../Authentication/Presentation/Cubit/authCubit.dart';
// ignore: unused_import
import '../../../config/timePost.dart';
import '../../../Person/Presentation/Screen/Profile.dart';
import '../Cubit/ChatRoomBloc/ChatRoomCubit.dart';
import '../Cubit/ChatRoomBloc/ChatRoomState.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  //currentUser
  UserApp? currentUser;


  void deleteChatRoom(BuildContext context, String chatID) async {
    await context.read<Chatroomcubit>().deleteChatRoom(chatID);
  }

  bool checkEnableNotify(String idUser) {
    return currentUser!.EnableNotify!.contains(idUser);
  }

  void toggle_Notify(BuildContext context, String idUser) async {
    //check enable notify
    final bool isEnable = checkEnableNotify(idUser);
    if (isEnable) {
      //smoth Ui
      setState(() {
        currentUser!.EnableNotify!.removeWhere((t) => t == idUser);
      });
      await context
          .read<Chatroomcubit>()
          .refuseNotify(idUser)
          .catchError((onError) {
        setState(() {
          currentUser!.EnableNotify!.add(idUser);
        });
      });
      return;
    }
    //smoth Ui
    setState(() {
      currentUser!.EnableNotify!.add(idUser);
    });
    await context
        .read<Chatroomcubit>()
        .allowNotify(idUser)
        .catchError((onError) {
      setState(() {
        currentUser!.EnableNotify!.removeWhere((t) => t == idUser);
      });
    });
  }

  //openCHat
  void openChat(UserApp user) async {
    final isHaveChat = await context.read<Chatroomcubit>().checkChat(user.id);
    if (isHaveChat) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (c) => ChatScreen(
                    user: user,
                    isFromHome: true,
                  )));
    } else {
      final ChatRoom chat =
          await context.read<Chatroomcubit>().createChat(user.id);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (c) => ChatScreen(
                    chat: chat,
                    user: user,
                    isFromHome: true,
                  )));
    }
  }

  void openContainChat(ChatRoom chat_room, UserApp otherUser) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => ChatScreen(
                  chat: chat_room,
                  user: otherUser,
                  isFromHome: true,
                )));
  }

  String displayMessage(ChatRoom chat_room) {
    List<Message> listMessage = chat_room.listMessage;
    if (listMessage.isEmpty) {
      return 'Start a chat';
    } else {
      Message lastMessage = listMessage.last;
      if (lastMessage.type == MessageType.Image) {
        return 'Sent an image';
      } else if (lastMessage.type == MessageType.Video) {
        return 'Sent a video';
      } else if (lastMessage.type == MessageType.Audio) {
        return 'Sent a audio';
      }
      return lastMessage.content;
    }
  }

  void openProfiles() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => Profile(
                  userInformation: currentUser,
                )));
  }

  void openSearch(List<UserApp>? listFriends) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => SearchUser(
                  listUser: listFriends,
                )));
  }

  bool isSeenMessage(ChatRoom chat_room) {
    if (chat_room.listMessage.isNotEmpty &&
        chat_room.listMessage.last.senderID != currentUser!.id) {
      return chat_room.listMessage.last.seen;
    }
    return true;
  }

  int numberMessageNotSeen(ChatRoom chat_room) {
    if (chat_room.listMessage.last.senderID == currentUser!.id) {
      return 0;
    }
    final List listMessageNotSeen =
        chat_room.listMessage.where((mess) => mess.seen == false).toList();
    return listMessageNotSeen.length;
  }

  @override
  void initState() {
    currentUser = context.read<AuthCubit>().userData;
    Future.wait([context.read<ListFriendcubit>().getListFriends(),
    context.read<Chatroomcubit>().getAllChat()]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      color: Theme.of(context).colorScheme.surface,
      child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [SliverToBoxAdapter(child: _headerWidget())];
          },
          body: _bodyWiget()),
    );
  }


  Widget _headerWidget() {
    final size = MediaQuery.of(context).size;
    return BlocBuilder<ListFriendcubit, ListFriendstate>(
        builder: (context, state) {
          print(state);
      if (state is loadingListFriend) {
        return Container(
          height: size.height * 0.3,
          width: size.width,
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
          child: Center(
            child: Loading(
                height_width: size.width * 0.1,
                color: Theme.of(context).colorScheme.primaryContainer),
          ),
        );
      } else if (state is onErrorListFriend) {
        return Center(
          child: Text(
            state.error,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primaryContainer),
          ),
        );
      } else if (state is getListFriendSuccess) {
        //get list friend
        List<UserApp> listFriends = state.listFriends ?? [];
        return Container(
          height: size.height * 0.3,
          width: size.width,
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
          child: Column(
            children: [
              //AppBarr
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => openSearch(listFriends),
                    child: Container(
                      height: size.width * 0.1,
                      width: size.width * 0.1,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 2)),
                      child: Icon(
                        Icons.search_rounded,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ),
                  Text(
                    'Home',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primaryContainer),
                  ),
                  GestureDetector(
                    onTap: openProfiles,
                    child: Avatar(
                      height_width: 0.13,
                      user: currentUser,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              //ListUsser
              Expanded(
                  child: listFriends.isEmpty
                      ? Center(
                          child: Text(
                            "No friends yet",
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: listFriends.length,
                          itemBuilder: (context, index) =>
                              _itemUser(listFriends[index])))
            ],
          ),
        );
      }
      else{
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    });
  }

  Widget _bodyWiget() {
    final size = MediaQuery.of(context).size;
    return BlocBuilder<Chatroomcubit, Chatroomstate>(builder: (context, state) {
      print(state);
      if (state is onError) {
        return Center(
          child: Text(
            state.message!,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primaryContainer),
          ),
        );
      } else if (state is getChatSuccess) {
        List<ChatRoom> listChat = state.listChat ?? [];
        List<UserApp> listUsers = context.read<AuthCubit>().allUser ?? [];
        return Container(
          height: size.height * 0.7,
          width: size.width,
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 5,
                width: size.width * 0.2,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(20)),
              ),
              Expanded(
                  child: listChat.isEmpty
                      ? Center(
                          child: Text(
                            "No Chats yet",
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                        )
                      : ListView.builder(
                        physics:const AlwaysScrollableScrollPhysics(),
                          itemCount: listChat.length,
                          itemBuilder: (context, index) =>
                              _itemChat(listChat[index], listUsers)))
            ],
          ),
        );
      }
      else{
        return Container(
          height: size.height * 0.7,
          width: size.width,
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Center(
            child: Loading(
                height_width: size.width * 0.1,
                color: Theme.of(context).colorScheme.primaryContainer),
          ),
        );
      }
    });
  }

  Widget _itemUser(UserApp user) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: GestureDetector(
        onTap: () => openChat(user),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                    height: size.width * 0.15 + 10,
                    width: size.width * 0.15 + 10,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3)),
                    padding: const EdgeInsets.all(5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: user.avatarUrl!.isEmpty
                          ? const Image(
                              image: AssetImage('assets/images/person.jpg'),
                              fit: BoxFit.cover,
                            )
                          : CacheImage(
                              imageUrl: user.avatarUrl!,
                              widthPlachoder: size.width * 0.15 + 10,
                              heightPlachoder: size.width * 0.15 + 10),
                    )),
                user.isOnline!
                    ? Container(
                        height: 15,
                        width: 15,
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle),
                      )
                    : Container()
              ],
            ),
            //Name
            Text(
              user.userName,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primaryContainer),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemChat(ChatRoom chat_room, List<UserApp> listUser) {
    final size = MediaQuery.of(context).size;
    // lấy ra user còn lại trong room
    String otherID =
        chat_room.participant.firstWhere((test) => test != currentUser!.id);
    //từ id lấy ra cả UserAPP
    UserApp otherUser = listUser.firstWhere((test) => test.id == otherID);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () => openContainChat(chat_room, otherUser),
        child: Slidable(
          endActionPane: ActionPane(motion: const ScrollMotion(), children: [
            CustomSlidableAction(
                flex: 1,
                onPressed: (context) => toggle_Notify(context, otherUser.id),
                child: Container(
                  height: size.width * 0.1,
                  width: size.width * 0.1,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surface),
                  child: Icon(
                    checkEnableNotify(otherUser.id)
                        ? Icons.notifications
                        : Icons.notifications_off,
                    size: 28,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                )),
            CustomSlidableAction(
                flex: 1,
                onPressed: (context) =>
                    deleteChatRoom(context, chat_room.ID_Room),
                child: Container(
                  height: size.width * 0.1,
                  width: size.width * 0.1,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.red),
                  child: Icon(
                    Icons.delete,
                    size: 28,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                )),
          ]),
          child: SizedBox(
            width: size.width,
            child: Row(
              children: [
                Avatar(
                  height_width: 0.13,
                  user: otherUser,
                  border: Border.all(
                      width: 3, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUser.userName,
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.surface,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: size.width * 0.72 - 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: size.width * 0.5,
                            child: Text(
                              displayMessage(chat_room),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isSeenMessage(chat_room)
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context).colorScheme.surface,
                                  fontWeight: isSeenMessage(chat_room)
                                      ? FontWeight.w400
                                      : FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          chat_room.listMessage.isNotEmpty
                              ? Row(
                                  children: [
                                    numberMessageNotSeen(chat_room) > 0
                                        ? Container(
                                            height: size.width * 0.04,
                                            width: size.width * 0.04,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red),
                                            alignment: Alignment.center,
                                            child: Text(
                                              numberMessageNotSeen(chat_room)
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        : Container(),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      '${chat_room.listMessage.last.sendAt.toDate().hour}:${chat_room.listMessage.last.sendAt.toDate().minute}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: isSeenMessage(chat_room)
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                          fontWeight: isSeenMessage(chat_room)
                                              ? FontWeight.w400
                                              : FontWeight.w700),
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
