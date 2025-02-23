
import 'package:chat_app/Authentication/Presentation/Cubit/authCubit.dart';
import 'package:chat_app/Chat/Data/ChatData.dart';
import 'package:chat_app/Chat/Presentation/Cubit/DisplayMessage/DisplayCubit.dart';
import 'package:chat_app/Chat/Presentation/Cubit/Home/HomeChatCubit.dart';
import 'package:chat_app/Config/Navigation/NavigationCubit.dart';
import 'package:chat_app/Person/Presentation/Cubit/personCubit.dart';
import 'package:chat_app/Theme/Theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Authentication/Data/UserData.dart';
import 'Authentication/Presentation/Screen/authScreen.dart';
import 'Person/Data/Persondata.dart';
import 'firebase_options.dart';

void main() async {
  //native splash
  await Future.delayed(const Duration(seconds: 3));
  FlutterNativeSplash.remove();
  //firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  await dotenv.load(fileName: ".env");
  //supabase setup
  await Supabase.initialize(
    url: dotenv.env['URL_SUPABASE']!,
    anonKey: dotenv.env['ANONKEY_SUPABASE']!
  );

  runApp( MyApp());
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
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (create)=> AuthCubit(userRepo: userRepo)..checkAuth()),
          BlocProvider(create: (create)=>HomeChatCubit(chatRepo: chatRepo)),
          BlocProvider(create: (create)=>DisplayCubit(chatRepo: chatRepo)),
          BlocProvider(create: (create)=>NavigationCubit()),
          BlocProvider(create: (create)=>Personcubit(person_repo: person_repo, userRepo: userRepo))
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: lightMode,
          home: const AuthScreen(),
        )
    );
  }
}


