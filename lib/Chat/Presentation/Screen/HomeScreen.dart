
import 'package:chat_app/Config/Navigation/NavigationCubit.dart';
import 'package:chat_app/Config/Navigation/NavigationState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Cubit/Home/HomeChatCubit.dart';
import '../../../Person/Presentation/Screen/SettingWidget.dart';
import 'SocialWidget.dart';
import 'homeWidget.dart';



class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    context.read<HomeChatCubit>().getListUser();
    context.read<HomeChatCubit>().getAllChat();
    super.initState();
  }

  List<Widget> screen = [home(), SocialScreen(), SettingScreen()];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit,NavigationState>(
        builder: (context, stateNav){
          return Scaffold(
              body: screen[stateNav.index],
              bottomNavigationBar: BottomNavigationBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                currentIndex: stateNav.index,
                  onTap: context.read<NavigationCubit>().changeIndex,
                  items:const [
                    BottomNavigationBarItem(
                      label:'Message' ,
                        icon: Icon(Icons.message, size: 28,)
                    ),
                    BottomNavigationBarItem(
                        label:'Social' ,
                        icon: Icon(Icons.public, size: 28,)
                    ),
                    BottomNavigationBarItem(
                        label:'Setting' ,
                        icon: Icon(Icons.settings, size: 28,)
                    ),
                  ]
              ),
          );
        }
    );
  }


}

