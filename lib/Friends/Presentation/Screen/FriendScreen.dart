// ignore_for_file: must_be_immutable

import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Config/Avatar.dart';
import 'package:chat_app/Friends/Presentation/Cubit/FriendCubit.dart';
import 'package:chat_app/Friends/Presentation/Cubit/FriendState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendScreen extends StatefulWidget {
  UserApp? userApp;
  FriendScreen({super.key, this.userApp});

  @override
  State<FriendScreen> createState() => _FriendscreenState();
}

class _FriendscreenState extends State<FriendScreen> {
  List<Widget> listTab = const [
    Tab(
      text: 'Required',
    ),
    Tab(
      text: 'Suggest',
    ),
    Tab(
      text: 'Friends',
    ),
  ];

  void addFriends(UserApp user) async {
    //smoth UI
    setState(() {
      user.requiredAddFriend!.add(widget.userApp!.id);
    });
    await context.read<Friendcubit>().addFriends(user.id).catchError((e) {
      setState(() {
        user.requiredAddFriend!.remove(widget.userApp!.id);
      });
    });
  }

  void deleteRequired(UserApp userRequired, List<UserApp> listRequired) async {
    //smoth UI
    setState(() {
      listRequired.removeWhere((user) => user.id == userRequired.id);
    });
    await context
        .read<Friendcubit>()
        .deleteRequired(userRequired.id)
        .catchError((e) {
      setState(() {
        listRequired.add(userRequired);
      });
    });
  }

  void confirmFriends(UserApp userRequired, List<UserApp> listFriends,
      List<UserApp> listRequired) async {
    setState(() {
      listRequired.removeWhere((user) => user.id == userRequired.id);
      listFriends.add(userRequired);
    });
    await context
        .read<Friendcubit>()
        .confirmFriends(userRequired.id)
        .catchError((e) {
      setState(() {
        listRequired.add(userRequired);
        listFriends.removeWhere((user) => user.id == userRequired.id);
      });
    });
  }

  void unFriends(UserApp user, List<UserApp> listFriends) async {
    //smoth UI
    setState(() {
      listFriends.removeWhere((userDel) => user.id == userDel.id);
    });
    await context.read<Friendcubit>().unFriends(user.id).catchError((e) {
      setState(() {
        listFriends.add(user);
      });
    });
  }

  @override
  void initState() {
    context.read<Friendcubit>().fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              size: 30,
              color: Theme.of(context).colorScheme.surface,
            )),
        title: Text(
          'About Friends',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.surface),
        ),
      ),
      body: DefaultTabController(
          initialIndex: 0,
          length: listTab.length,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Tab bar
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TabBar(
                    tabs: listTab,
                    dividerHeight: 0,
                  )),
              //listUserContainText
              BlocConsumer<Friendcubit, Friendstate>(
                  builder: (context, state) {
                    print(state);
                    if (state is loadedPageFriends) {
                      List<UserApp> listUser = state.listUser ?? [];
                      List<UserApp> listFriends = state.listFriends ?? [];
                      List<UserApp> listRequired = state.listRequired ?? [];
                      return Expanded(
                          child: TabBarView(children: [
                        //required
                        listRequired.isNotEmpty
                            ? RefreshIndicator(
                                onRefresh: () =>
                                    context.read<Friendcubit>().fetchData(),
                                child: ListView.builder(
                                    itemCount: listRequired.length,
                                    itemBuilder: (context, index) => _itemUser(
                                        listRequired[index],
                                        'Required',
                                        listRequired,
                                        listFriends)),
                              )
                            : textCenter('No Required'),
                        //Suggest
                        RefreshIndicator(
                          onRefresh: () =>
                              context.read<Friendcubit>().fetchData(),
                          child: ListView.builder(
                              itemCount: listUser.length,
                              itemBuilder: (context, index) => _itemUser(
                                  listUser[index],
                                  'Suggest',
                                  listRequired,
                                  listFriends)),
                        ),
                        //Friends
                        listFriends.isNotEmpty
                            ? RefreshIndicator(
                                onRefresh: () =>
                                    context.read<Friendcubit>().fetchData(),
                                child: ListView.builder(
                                    itemCount: listFriends.length,
                                    itemBuilder: (context, index) =>
                                        _itemFriends(
                                            listFriends[index], listFriends)),
                              )
                            : textCenter("No Friends"),
                      ]));
                    } else {
                      return const Expanded(
                          child: Center(
                        child: CircularProgressIndicator(),
                      ));
                    }
                  },
                  listener: (context, state) {})
            ],
          )),
    );
  }

  Widget _itemUser(UserApp? user, String tab, List<UserApp> listRequired,
      List<UserApp> listFriends) {
    bool checkContainRequired() {
      return user!.requiredAddFriend!
          .any((value) => value == widget.userApp!.id);
    }

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Avatar(
            height_width: 0.17,
            user: user,
          ),
          const SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user!.userName,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.surface),
              ),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        tab == 'Required'
                            ? confirmFriends(user, listFriends, listRequired)
                            : addFriends(user);
                      },
                      style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          backgroundColor: checkContainRequired()
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4)
                              : Theme.of(context).colorScheme.primary),
                      child: Text(
                        tab == 'Required'
                            ? 'Confirm'
                            : (checkContainRequired()
                                ? 'Added'
                                : 'Add Friends'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                  const SizedBox(
                    width: 15.0,
                  ),
                  tab == 'Required'
                      ? ElevatedButton(
                          onPressed: () {
                            deleteRequired(user, listRequired);
                          },
                          style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.2)),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.surface,
                              fontWeight: FontWeight.w500,
                            ),
                          ))
                      : Container(),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _itemFriends(UserApp user, List<UserApp> listFriends) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Avatar(
            height_width: 0.15,
            user: user,
          ),
          const SizedBox(
            width: 15,
          ),
          Text(
            user.userName,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.surface),
          ),
          const Spacer(),
          PopupMenuButton(
            padding: EdgeInsets.zero,
            menuPadding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            color: Theme.of(context).colorScheme.primary,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: '',
                child: Text(
                  'unFriends',
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.surface),
                ),
              )
            ],
            onSelected: (value) => unFriends(user, listFriends),
          )
        ],
      ),
    );
  }

  Widget textCenter(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.surface,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}
