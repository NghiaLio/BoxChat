// ignore_for_file: deprecated_member_use, use_build_context_synchronously, must_be_immutable

import 'package:chat_app/Authentication/Presentation/Cubit/authCubit.dart';
import 'package:chat_app/Chat/Presentation/Screen/ChatScreen.dart';
import 'package:chat_app/config/Navigation/NavigationCubit.dart';
import 'package:chat_app/config/Navigation/NavigationState.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Authentication/Domains/Entity/User.dart';
import '../../../SocialMedia/Data/SocialData.dart';
import '../../../SocialMedia/Presentation/Cubits/SocialCubits.dart';
import '../../Data/ChatData.dart';
import '../Cubit/ChatRoomBloc/ChatRoomCubit.dart';
import '../../../Person/Presentation/Screen/SettingWidget.dart';
import '../../../SocialMedia/Presentation/Screen/SocialWidget.dart';
import '../Cubit/FriendBloc/friendCubit.dart';
import 'homeWidget.dart';

class HomeScreen extends StatefulWidget {
  RemoteMessage? initialMessage;
  HomeScreen({super.key, this.initialMessage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Future<bool> _onWillPop() async {
    // Set user status to offline before exiting
    context.read<AuthCubit>().updateIsOnline(false);

    // Allow the app to close
    return true;
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (widget.initialMessage != null) {
      _handleMessage(widget.initialMessage!);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    print('hello ${message.data}');
    context.read<NavigationCubit>().changeIndex(0);
    final listUser = context.read<Chatroomcubit>().listUsers!;
    final String senderID = message.data['senderID'];
    final UserApp receiveUser =
        listUser.firstWhere((user) => user.id == senderID);

    print(receiveUser.userName);
    Future.delayed(const Duration(milliseconds: 500));
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            isFromHome: true,
            user: receiveUser,
          ),
        ));
    // 👈 Điều hướng đến trang cụ thể
  }

  @override
  void initState() {
    // Add observer to listen for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    // for setting user status to active
    context.read<AuthCubit>().updateIsOnline(true);
    // SystemChannels.lifecycle.setMessageHandler((message) {
    //   if (message!.contains('pause')) {
    //     context.read<AuthCubit>().updateIsOnline(false);
    //   }
    //   if (message.contains('resume')) {

    //     context.read<AuthCubit>().updateIsOnline(true);
    //   }
    //   return Future.value(message);
    // });

    setupInteractedMessage();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print(state);
    if (state == AppLifecycleState.resumed) {
      // App is resumed, fetch data again
      // context.read<HomeChatCubit>().getAllUsers();
      context.read<AuthCubit>().updateIsOnline(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // App is paused, set user status to offline
      context.read<AuthCubit>().updateIsOnline(false);
    }
  }

  @override
  void dispose() {
    // Remove observer when the widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  final chatRepo = ChatData();
    final social_repo = Socialdata();

  List<Widget> screen = [
      const home(),
      const SocialScreen(),
      const SettingScreen()
    ];
  @override
  Widget build(BuildContext context) {
    
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) =>
                  ListFriendcubit(chatRepo: chatRepo)),
          BlocProvider(
              create: (context) => Chatroomcubit(chatRepo: chatRepo)
                ),
          BlocProvider(create: (create) => NavigationCubit()),
          BlocProvider(
              create: (create) => Socialcubits(socialRepo: social_repo)),
         
        ],
        child: WillPopScope(
          onWillPop: _onWillPop,
          child: BlocBuilder<NavigationCubit, NavigationState>(
              builder: (context, stateNav) {
            return Scaffold(
              //khong rebuid lai widget
              body: IndexedStack(
                index: stateNav.index,
                children: screen,
              ),
              bottomNavigationBar: BottomNavigationBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  currentIndex: stateNav.index,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  unselectedItemColor: Theme.of(context).colorScheme.onSurface,
                  onTap: context.read<NavigationCubit>().changeIndex,
                  items: const [
                    BottomNavigationBarItem(
                        label: 'Message',
                        icon: Icon(
                          Icons.message,
                          size: 28,
                        )),
                    BottomNavigationBarItem(
                        label: 'Social',
                        icon: Icon(
                          Icons.public,
                          size: 28,
                        )),
                    BottomNavigationBarItem(
                        label: 'Setting',
                        icon: Icon(
                          Icons.settings,
                          size: 28,
                        )),
                  ]),
            );
          }),
        ));
  }
}
