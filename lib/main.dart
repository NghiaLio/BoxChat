// ignore_for_file: non_constant_identifier_names

import 'package:chat_app/Authentication/Presentation/Cubit/authCubit.dart';
import 'package:chat_app/Chat/Data/ChatData.dart';
import 'package:chat_app/Chat/Presentation/Cubit/DisplayMessage/DisplayCubit.dart';
import 'package:chat_app/Person/Presentation/Cubit/ThemeCubit.dart';
import 'package:chat_app/Friends/Data/FriendData.dart';
import 'package:chat_app/Friends/Presentation/Cubit/FriendCubit.dart';
import 'package:chat_app/Person/Presentation/Cubit/personCubit.dart';
import 'package:chat_app/SocialMedia/Data/SocialData.dart';
// ignore: unused_import
import 'package:chat_app/SocialMedia/Presentation/Cubits/SocialCubits.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Authentication/Data/UserData.dart';
import 'Authentication/Presentation/Screen/authScreen.dart';
import 'Person/Data/Persondata.dart';
import 'firebase_options.dart';

RemoteMessage? _initialMessage;

void main() async {
  //native splash
  await Future.delayed(const Duration(seconds: 3));
  FlutterNativeSplash.remove();
  //firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  await dotenv.load(fileName: ".env");
  //supabase setup
  await Supabase.initialize(
      url: dotenv.env['URL_SUPABASE']!,
      anonKey: dotenv.env['ANONKEY_SUPABASE']!);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final userRepo = UserData();
  final chatRepo = ChatData();
  final person_repo = Persondata();
  final social_repo = Socialdata();
  final friend_repo = FriendData();

  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (create) => AuthCubit(userRepo: userRepo)
                ..checkAuth()
                ..getAllUser()),
          BlocProvider(create: (create) => DisplayCubit(chatRepo: chatRepo)),
          BlocProvider(
              create: (create) =>
                  Personcubit(person_repo: person_repo, userRepo: userRepo)),
          BlocProvider(create: (create) => Themecubit()..loadTheme()),
          BlocProvider(
              create: (create) => Friendcubit(friendsRepo: friend_repo)),
        ],
        child: BlocBuilder<Themecubit, ThemeState>(builder: (context, state) {
          final ThemeData theme = state.themeData;
          return MaterialApp(
            title: 'Zago',
            theme: theme,
            home: AuthScreen(
              initialMessage: _initialMessage,
            ),
          );
        }));
  }
}
