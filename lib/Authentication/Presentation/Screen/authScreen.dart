import 'package:chat_app/Authentication/Presentation/Cubit/authCubit.dart';
import 'package:chat_app/Authentication/Presentation/Cubit/authState.dart';
import 'package:chat_app/Authentication/Presentation/Screen/LogIn.dart';
import 'package:chat_app/Config/TopSnackBar.dart';
import 'package:chat_app/Chat/Presentation/Screen/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit,authState>(
        builder: (context, state){
          print(state);
          if(state is UnAuthenticated){
            return const Login();
          }else if(state is Authenticated){
            return HomeScreen();
          }else{
            return const Scaffold(body: Center(child: CircularProgressIndicator(),),);
          }
        },
        listener: (context, state){
          if(state is FailAuth){
            showSnackBar.show_error(state.mess, context);
          }
        }
    );
  }
}
