import 'package:chat_app/Authentication/Presentation/Cubit/authCubit.dart';
import 'package:chat_app/Components/Avatar.dart';
import 'package:chat_app/Components/Navigation/NavigationCubit.dart';
import 'package:chat_app/Person/Presentation/Screen/Profile.dart';
import 'package:chat_app/Person/Presentation/Screen/SettingAccount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Authentication/Domains/Entity/User.dart';
import '../../../Friends/Presentation/Screen/FriendScreen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  UserApp? currentUser;

  void logout() async {
    await context.read<AuthCubit>().logOut();
    context.read<NavigationCubit>().changeIndex(0);
  }

  void tapToEditAccount() async {
    final UserApp? userUpdate = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => SettingAccount(
                  user: currentUser,
                )));
    setState(() {
      currentUser = userUpdate;
    });
    await refresh();
  }

  void tapToProfile(UserApp? user) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => Profile(
                  userInformation: user,
                )));
  }

  void tapToAddFriend() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => FriendScreen(
                  userApp: currentUser,
                )));
  }

  Future<void> refresh() async {
    await context.read<AuthCubit>().getUser();
  }

  @override
  void initState() {
    currentUser = context.read<AuthCubit>().userData;
    print(currentUser!.avatarUrl);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
        height: size.height,
        width: size.width,
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //AppBarr
                  SizedBox(
                    height: size.height * 0.1,
                    child: Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).colorScheme.primaryContainer),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  //Main
                  Container(
                    height: size.height * 0.75 + 10,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    child: _mainSetting(context),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Widget _mainSetting(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            //display person information
            GestureDetector(
              onTap: () => tapToProfile(currentUser),
              child: Row(
                children: [
                  Avatar(
                    height_width: 0.2,
                    user: currentUser,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser!.userName,
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currentUser!.email,
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w400),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Divider(
              height: 1.0,
              thickness: 1,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(
              height: 20,
            ),
            //other function
            _itemFunction(
                context,
                Icons.account_box_rounded,
                'Account',
                'Change name,num phone, avatar, password',
                () => tapToEditAccount()),
            _itemFunction(context, Icons.message, 'Chat',
                'Theme, wallpaper, chat history', null),
            _itemFunction(context, Icons.notifications_active, 'Notifications',
                'Message, group & call tones', null),
            _itemFunction(context, Icons.help, 'Help',
                'FAQ, contact us, privacy policy', null),
            _itemFunction(context, Icons.person_add_alt, 'Add friend',
                'Invite friends, contacts', () => tapToAddFriend()),
            _itemFunction(context, Icons.logout, 'Log out',
                'Log out of all devices', () => logout()),
          ],
        ),
      ),
    );
  }

  Widget _itemFunction(BuildContext context, IconData icon, String title,
      String detail, Function()? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade300,
                child: Center(
                  child: Icon(
                    icon,
                    size: 26,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7 - 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      detail,
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
