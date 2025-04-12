// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Authentication/Presentation/Cubit/authCubit.dart';
import 'package:chat_app/Person/Presentation/Screen/Profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Authentication/Domains/Entity/User.dart';

class Searchsocial extends StatefulWidget {
  UserApp? user;
  Searchsocial({super.key, this.user});

  @override
  State<Searchsocial> createState() => _SearchsocialState();
}

class _SearchsocialState extends State<Searchsocial> {
  bool ishaveText = false;
  final searchController = TextEditingController();
  List<Widget> listTab = const [
    Tab(
      text: 'User',
    ),
    Tab(
      text: 'Post',
    ),
    Tab(
      text: 'Other',
    ),
  ];
  List<UserApp>? listUser;
  List<UserApp> listSearchUser = [];
  void clearText() {
    searchController.clear();
  }

  void search(String value) {
    print(value);
    final List<UserApp> listUserContainText = listUser!
        .where((user) => user.userName.contains(value) == true)
        .toList();
    setState(() {
      listSearchUser = listUserContainText;
    });
  }

  void fetchAllUser() async {
    final listUserData =
        context.read<AuthCubit>().allUser;
    setState(() {
      listUser = listUserData;
    });
  }

  void viewProfile(UserApp? user) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => Profile(
                  userInformation: user,
                )));
  }

  @override
  void initState() {
    fetchAllUser();
    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        setState(() {
          ishaveText = true;
        });
      } else {
        setState(() {
          ishaveText = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: Column(
          children: [
            // App bar
            Container(
              height: MediaQuery.of(context).size.height * 0.1 + 10,
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).colorScheme.primary,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 40, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        size: 28,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 26,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: TextField(
                              controller: searchController,
                              onChanged: (value) => search(value),
                              decoration: const InputDecoration(
                                  hintText: 'Search', border: InputBorder.none),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.surface,
                                  fontWeight: FontWeight.w500),
                            ),
                          )),
                          const SizedBox(
                            width: 5,
                          ),
                          ishaveText
                              ? IconButton(
                                  onPressed: clearText,
                                  icon: Icon(
                                    Icons.cancel,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ))
                              : Container()
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                child: DefaultTabController(
              initialIndex: 0,
              length: listTab.length,
              child: Column(
                children: [
                  //Tab bar
                  TabBar(
                      // tabAlignment: TabAlignment.startOffset,
                      dividerColor: Colors.transparent,
                      tabs: listTab),
                  // List user
                  Expanded(
                    child: TabBarView(children: [
                      _displaySearchUser(),
                      _displaySearchMessage(),
                      _displaySearchOther()
                    ]),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget _displaySearchUser() {
    return listSearchUser.isEmpty || searchController.text.isEmpty
        ? Center(
            child: Text(
              'No result!',
              style: TextStyle(
                  fontSize: 18, color: Theme.of(context).colorScheme.primary),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.only(top: 10),
            itemCount: listSearchUser.length,
            itemBuilder: (context, index) => GestureDetector(
                  onTap: () => viewProfile(listSearchUser[index]),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: listSearchUser[index]
                                  .avatarUrl!
                                  .isNotEmpty
                              ? CachedNetworkImageProvider(
                                  listSearchUser[index].avatarUrl!)
                              : const AssetImage('assets/images/person.jpg'),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          listSearchUser[index].userName,
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.surface,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                ));
  }

  Widget _displaySearchMessage() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.sentiment_very_dissatisfied,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
        Text(
          "Ohh.Feature not upgrade yet",
          style: TextStyle(
              fontSize: 18, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    ));
  }

  Widget _displaySearchOther() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.sentiment_very_dissatisfied,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
        Text(
          "Ohh.Feature not upgrade yet",
          style: TextStyle(
              fontSize: 18, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    ));
  }
}
