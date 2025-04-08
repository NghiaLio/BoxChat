import 'package:chat_app/Authentication/Presentation/Cubit/authCubit.dart';
import 'package:chat_app/Authentication/Presentation/Cubit/authState.dart';
import 'package:chat_app/Authentication/Presentation/Screen/LogIn.dart';
import 'package:chat_app/Components/CircleProgressIndicator.dart';
import 'package:chat_app/Components/TopSnackBar.dart';
import 'package:chat_app/Chat/Presentation/Screen/HomeScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthScreen extends StatefulWidget {
  RemoteMessage? initialMessage;
  AuthScreen({super.key, this.initialMessage});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, authState>(builder: (context, state) {
      print(state);
      if (state is UnAuthenticated) {
        return const Login();
      } else if (state is Authenticated) {
        return HomeScreen(initialMessage: widget.initialMessage,);
      } else {
        return Scaffold(
          backgroundColor: const Color.fromRGBO(113, 224, 12, 1.0),
          body: Center(
            child: Loading(
                height_width: MediaQuery.of(context).size.width * 0.1,
                color: Theme.of(context).colorScheme.primaryContainer),
          ),
        );
      }
    }, listener: (context, state) {
      if (state is FailAuth) {
        showSnackBar.show_error(state.mess, context);
      }
    });
  }
}
